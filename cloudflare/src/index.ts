/**
 * 教师工资统计系统 - Cloudflare Workers 后端 v2
 * 功能：账号体系（管理员/教师）、排课与学生名单、打卡、审核、工资报表、密码审核、邮件同步
 */

import { pinyin } from 'pinyin-pro';

interface Env {
  DB: any;
  ASSETS: any;
  JWT_SECRET?: string;
}

const JWT_TTL_SECONDS = 72 * 3600;
const FALLBACK_SECRET = 'school-salary-fallback-secret-2026';
const DEFAULT_PASSWORD_SUFFIX = '123456';

const enc = new TextEncoder();
const dec = new TextDecoder();

/** 姓名转拼音小写（去掉声调与符号），非中文字符原样保留后转小写 */
function pinyinLower(name: string): string {
  const parts = pinyin(name, { toneType: 'none', type: 'array', nonZh: 'consecutive' });
  const s = parts.join('').toLowerCase().replace(/[^a-z0-9]/g, '');
  return s || 'teacher';
}

/** 课次编号：教师中文姓名拼音首字母（大写）+ D + 课次号，如梁玉叶第 17 节为 LYYD17 */
function makeLessonLabel(teacherName: any, lessonNo: number): string {
  const parts = pinyin(str(teacherName), { toneType: 'none', type: 'array', nonZh: 'consecutive' });
  const initials = parts.map(p => p.charAt(0)).join('').toUpperCase().replace(/[^A-Z0-9]/g, '');
  return initials + 'D' + lessonNo;
}

/** 教师初始密码 = 姓名拼音小写 + 123456（注册与管理员重置规则一致） */
function teacherInitialPassword(name: string): string {
  return pinyinLower(name) + DEFAULT_PASSWORD_SUFFIX;
}

/** 密码只允许英文、数字和英文符号，禁止中文与空格 */
function assertAsciiPassword(pwd: string): void {
  if (!/^[\x21-\x7E]+$/.test(pwd)) {
    throw new ApiError(500, '密码不能包含中文或空格，请使用英文、数字和符号');
  }
}

class ApiError extends Error {
  code: number;
  constructor(code: number, message: string) {
    super(message);
    this.code = code;
  }
}

function jsonResponse(data: any, status = 200): Response {
  return new Response(JSON.stringify(data), {
    status,
    headers: {
      'content-type': 'application/json; charset=utf-8',
      'access-control-allow-origin': '*',
      'access-control-allow-headers': 'Content-Type, Authorization',
      'access-control-allow-methods': 'GET, POST, PUT, DELETE, OPTIONS',
      'cache-control': 'no-store'
    }
  });
}

const ok = (data: any = null) => jsonResponse({ code: 200, msg: 'success', data });
const fail = (msg: string, code = 500) => jsonResponse({ code, msg, data: null });

async function readJson(request: Request): Promise<any> {
  try {
    const text = await request.text();
    if (!text) return {};
    return JSON.parse(text);
  } catch {
    throw new ApiError(500, '请求体不是合法 JSON');
  }
}

function bytesToB64(bytes: Uint8Array): string {
  let s = '';
  for (let i = 0; i < bytes.length; i++) s += String.fromCharCode(bytes[i]);
  return btoa(s);
}

function b64ToBytes(b64: string): Uint8Array {
  const s = atob(b64);
  const out = new Uint8Array(s.length);
  for (let i = 0; i < s.length; i++) out[i] = s.charCodeAt(i);
  return out;
}

function b64urlFromBytes(bytes: Uint8Array): string {
  return bytesToB64(bytes).replace(/\+/g, '-').replace(/\//g, '_').replace(/=+$/, '');
}

function b64urlFromString(str: string): string {
  return b64urlFromBytes(enc.encode(str));
}

function b64urlToBytes(str: string): Uint8Array {
  const padded = str + '='.repeat((4 - (str.length % 4)) % 4);
  return b64ToBytes(padded.replace(/-/g, '+').replace(/_/g, '/'));
}

function b64urlToString(str: string): string {
  return dec.decode(b64urlToBytes(str));
}

function nowStr(offsetMs = 0): string {
  const t = new Date(Date.now() + offsetMs + 8 * 3600 * 1000);
  return t.toISOString().replace('T', ' ').slice(0, 19);
}

function str(v: any): string {
  return v === null || v === undefined ? '' : String(v).trim();
}

/** 'YYYY-MM-DD' + n 天 */
function dateAddDays(dateStr: string, days: number): string {
  const d = new Date(dateStr + 'T00:00:00Z');
  d.setUTCDate(d.getUTCDate() + days);
  return d.toISOString().slice(0, 10);
}

/** 星期几：0=周日 … 6=周六 */
function weekdayOf(dateStr: string): number {
  return new Date(dateStr + 'T00:00:00Z').getUTCDay();
}

/** 'YYYY-MM-DD HH:MM(:SS)' 加 n 分钟，返回同格式（秒保留） */
function timeAddMinutes(startStr: string, minutes: number): string {
  const t = new Date(String(startStr).replace(' ', 'T') + 'Z');
  t.setUTCMinutes(t.getUTCMinutes() + minutes);
  return t.toISOString().slice(0, 19).replace('T', ' ');
}

/** 规范化日期与时间输入 */
function normDate(v: any): string {
  const s = str(v);
  return /^\d{4}-\d{2}-\d{2}$/.test(s) ? s : '';
}

function normTime(v: any): string {
  const m = /^(\d{1,2}):(\d{2})$/.exec(str(v));
  if (!m) return '';
  const h = Number(m[1]);
  const mi = Number(m[2]);
  if (h > 23 || mi > 59) return '';
  return String(h).padStart(2, '0') + ':' + String(mi).padStart(2, '0');
}

/** 教师端可微调上课时间：接受 'YYYY-MM-DD HH:MM' 或 'YYYY-MM-DDTHH:MM' */
function normDateTime(v: any): string {
  const s = str(v).replace('T', ' ');
  const m = /^(\d{4}-\d{2}-\d{2}) (\d{1,2}):(\d{2})(?::(\d{2}))?$/.exec(s);
  if (!m) return '';
  const time = normTime(m[2] + ':' + m[3]);
  if (!time) return '';
  return m[1] + ' ' + time + ':' + (m[4] || '00');
}


/** 年级编码：K 幼儿园、P 小学、J 初中、H 高中 */
const GRADE_LABELS: Record<string, string> = {
  K0: '幼儿园小班', K1: '幼儿园中班', K2: '幼儿园大班',
  P0: '幼小衔接', P1: '一年级', P2: '二年级', P3: '三年级', P4: '四年级', P5: '五年级',
  J0: '小初衔接', J1: '初一', J2: '初二', J3: '初三',
  H0: '初高衔接', H1: '高一', H2: '高二', H3: '高三'
};

/** 规范化年级编码，非法返回空串 */
function normalizeGradeCode(v: any): string {
  const s = str(v).toUpperCase();
  return Object.prototype.hasOwnProperty.call(GRADE_LABELS, s) ? s : '';
}

/** 从班级名称推断年级编码：兼容旧数据 G1-G9（5+4 学制）与中文年级名 */
function gradeFromClassName(name: any): string {
  const s = str(name);
  const direct = /(?:^|[^A-Z0-9])([KPHJ][0-3])(?:[^0-9]|$)/.exec(s.toUpperCase());
  if (direct) {
    const code = normalizeGradeCode(direct[1]);
    if (code) return code;
  }
  const g = /^G(\d)/.exec(s.toUpperCase());
  if (g) {
    const n = Number(g[1]);
    if (n >= 1 && n <= 5) return 'P' + n;
    if (n === 6) return 'J0';
    if (n === 7) return 'J1';
    if (n === 8) return 'J2';
    if (n === 9) return 'J3';
  }
  const aliases: Array<[string, string]> = [
    ['小班', 'K0'], ['中班', 'K1'], ['大班', 'K2'],
    ['幼小衔接', 'P0'], ['一年级', 'P1'], ['二年级', 'P2'], ['三年级', 'P3'], ['四年级', 'P4'], ['五年级', 'P5'],
    ['小初衔接', 'J0'], ['初一', 'J1'], ['初二', 'J2'], ['初三', 'J3'],
    ['初高衔接', 'H0'], ['高一', 'H1'], ['高二', 'H2'], ['高三', 'H3']
  ];
  for (const [kw, code] of aliases) if (s.includes(kw)) return code;
  return '';
}

function resolveGradeCode(explicit: any, className: any): string {
  return normalizeGradeCode(explicit) || gradeFromClassName(className);
}

/** 班级名称三要素：年级 / 学科 / 班型，统一格式 "{年级}-{学科}-{班型}" */
const SUBJECT_OPTIONS = ['语文','数学','英语','物理','化学','生物','历史','地理','政治','科学'];
// 班型核心选项：基础班/卓越班 为主，保留 1对1/1对3/小班 等常见细分
const CLASS_TYPE_OPTIONS = ['基础班','卓越班','1对1','1对3','小班'];

function buildClassName(gradeCode: string, subject: string, classType: string): string {
  if (!gradeCode) return '';
  const sb = str(subject);
  const ct = str(classType);
  return gradeCode + (sb ? '-' + sb : '') + (ct ? '-' + ct : '');
}

/** 排课冲突检测：同一老师 / 同一教室 / 同一班级 在同一时间段 */
interface Slot { date: string; time: string; durationMinutes: number; }

function slotOverlap(aStart: string, aEnd: string, bStart: string, bEnd: string): boolean {
  return aStart < bEnd && aEnd > bStart;
}

function slotEndTime(date: string, time: string, minutes: number): string {
  return timeAddMinutes(date + ' ' + time, minutes);
}

async function detectScheduleConflict(
  env: Env,
  teacherId: number,
  classroomId: number | null | undefined,
  slots: Slot[],
  excludeIds: number[] = []
): Promise<string | null> {
  if (!slots.length) return null;
  const dates = Array.from(new Set(slots.map(s => s.date)));
  const rows = await env.DB.prepare(
    `SELECT sc.id, sc.teacher_id, sc.classroom_id, sc.planned_date, sc.planned_time, sc.duration_minutes
     FROM class_schedule sc
     WHERE (sc.teacher_id = ? OR sc.classroom_id = ?)
       AND sc.planned_date IN (${dates.map(() => '?').join(',')})
     ${excludeIds.length ? `AND sc.id NOT IN (${excludeIds.map(() => '?').join(',')})` : ''}`
  )
    .bind(teacherId, classroomId ?? 0, ...dates, ...excludeIds)
    .all();

  for (const r of (rows.results || []) as any[]) {
    const rStart = r.planned_date + ' ' + r.planned_time + ':00';
    const rEnd = slotEndTime(r.planned_date, r.planned_time, Number(r.duration_minutes || 120));
    for (const sl of slots) {
      const sStart = sl.date + ' ' + sl.time + ':00';
      const sEnd = slotEndTime(sl.date, sl.time, sl.durationMinutes);
      if (!slotOverlap(sStart, sEnd, rStart, rEnd)) continue;
      if (r.teacher_id === teacherId) {
        return '老师在 ' + sl.date + ' ' + sl.time + ' 已有排课（课次 #' + r.id + '）';
      }
      if (classroomId && r.classroom_id === classroomId) {
        return '教室在 ' + sl.date + ' ' + sl.time + ' 已被占用（课次 #' + r.id + '）';
      }
    }
  }
  return null;
}

/** 解析 { '1': '08:00', '2': '17:00' } 形式的星期上课时间（0=周日 … 6=周六） */
function parseDayTimes(v: any): Record<string, string> {
  const out: Record<string, string> = {};
  if (v && typeof v === 'object' && !Array.isArray(v)) {
    for (const k of Object.keys(v)) {
      const d = Number(k);
      if (!Number.isInteger(d) || d < 0 || d > 6) continue;
      const t = normTime(v[k]);
      if (t) out[String(d)] = t;
    }
  }
  return out;
}

function intOrNull(v: any): number | null {
  if (v === null || v === undefined || String(v).trim() === '') return null;
  const n = Number(v);
  return Number.isFinite(n) ? Math.trunc(n) : null;
}

function esc(s: any): string {
  return String(s === null || s === undefined ? '' : s)
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;');
}

// ---------------- 密码 ----------------

async function deriveBits(password: string, salt: Uint8Array, iterations: number): Promise<Uint8Array> {
  const keyMaterial = await crypto.subtle.importKey('raw', enc.encode(password), 'PBKDF2', false, ['deriveBits']);
  const bits = await crypto.subtle.deriveBits({ name: 'PBKDF2', salt, iterations, hash: 'SHA-256' }, keyMaterial, 256);
  return new Uint8Array(bits);
}

async function hashPassword(password: string): Promise<string> {
  const salt = crypto.getRandomValues(new Uint8Array(16));
  const hash = await deriveBits(password, salt, 100000);
  return `pbkdf2$100000$${bytesToB64(salt)}$${bytesToB64(hash)}`;
}

async function verifyPassword(password: string, stored: string): Promise<boolean> {
  try {
    const parts = String(stored || '').split('$');
    if (parts.length !== 4 || parts[0] !== 'pbkdf2') return false;
    const iterations = parseInt(parts[1], 10) || 100000;
    const salt = b64ToBytes(parts[2]);
    const expected = b64ToBytes(parts[3]);
    const actual = await deriveBits(password, salt, iterations);
    if (actual.length !== expected.length) return false;
    let diff = 0;
    for (let i = 0; i < actual.length; i++) diff |= actual[i] ^ expected[i];
    return diff === 0;
  } catch {
    return false;
  }
}

// ---------------- JWT ----------------

function jwtSecret(env: Env): string {
  return env.JWT_SECRET || FALLBACK_SECRET;
}

async function hmacKey(secret: string, usage: 'sign' | 'verify'): Promise<CryptoKey> {
  return crypto.subtle.importKey('raw', enc.encode(secret), { name: 'HMAC', hash: 'SHA-256' }, false, [usage]);
}

async function signToken(payload: Record<string, any>, secret: string): Promise<string> {
  const header = { alg: 'HS256', typ: 'JWT' };
  const body = b64urlFromString(JSON.stringify(header)) + '.' + b64urlFromString(JSON.stringify(payload));
  const key = await hmacKey(secret, 'sign');
  const sig = await crypto.subtle.sign('HMAC', key, enc.encode(body));
  return body + '.' + b64urlFromBytes(new Uint8Array(sig));
}

async function verifyToken(token: string, secret: string): Promise<any> {
  const seg = String(token || '').split('.');
  if (seg.length !== 3) throw new Error('bad token');
  const body = seg[0] + '.' + seg[1];
  const key = await hmacKey(secret, 'verify');
  const valid = await crypto.subtle.verify('HMAC', key, b64urlToBytes(seg[2]), enc.encode(body));
  if (!valid) throw new Error('bad signature');
  const payload = JSON.parse(b64urlToString(seg[1]));
  if (payload.exp && Date.now() >= Number(payload.exp) * 1000) throw new Error('token expired');
  return payload;
}

async function requireAuth(request: Request, env: Env): Promise<any> {
  const header = request.headers.get('Authorization') || '';
  if (!header.startsWith('Bearer ')) throw new ApiError(401, '缺少 Authorization');
  try {
    return await verifyToken(header.slice('Bearer '.length), jwtSecret(env));
  } catch {
    throw new ApiError(401, '登录已过期，请重新登录');
  }
}

async function currentUser(request: Request, env: Env): Promise<any> {
  const claims = await requireAuth(request, env);
  const user = await env.DB.prepare('SELECT * FROM sys_user WHERE id = ?').bind(claims.userId).first();
  if (!user) throw new ApiError(401, '用户不存在');
  if (Number(user.status) !== 1) throw new ApiError(401, '账号已停用');
  return user;
}

async function requireAdmin(request: Request, env: Env): Promise<any> {
  const user = await currentUser(request, env);
  if (user.role !== 'ADMIN') throw new ApiError(401, '无管理员权限');
  return user;
}

// ---------------- 设置 ----------------

async function getSetting(env: Env, key: string, fallback = ''): Promise<string> {
  const row = await env.DB.prepare('SELECT value FROM settings WHERE key = ?').bind(key).first();
  return row && row.value !== null && row.value !== undefined ? String(row.value) : fallback;
}

async function setSetting(env: Env, key: string, value: string): Promise<void> {
  await env.DB.prepare(
    'INSERT INTO settings (key, value) VALUES (?, ?) ON CONFLICT(key) DO UPDATE SET value = excluded.value'
  )
    .bind(key, value)
    .run();
}

// ---------------- 映射 ----------------

function mapUser(r: any) {
  return {
    id: r.id,
    username: r.username,
    name: r.name,
    nickname: r.nickname,
    avatar: r.avatar,
    role: r.role,
    phone: r.phone,
    email: r.email,
    campusId: r.campus_id,
    teacherId: r.teacher_id,
    status: r.status,
    createdAt: r.created_at
  };
}

async function userPayload(env: Env, user: any) {
  const base: any = mapUser(user);
  if (user.teacher_id) {
    const t = await env.DB.prepare('SELECT employee_no FROM teacher WHERE id = ?').bind(user.teacher_id).first();
    if (t) base.employeeNo = t.employee_no;
  }
  return base;
}

function mapTeacher(r: any) {
  return {
    id: r.id,
    name: r.name,
    employeeNo: r.employee_no,
    phone: r.phone,
    email: r.email,
    campusId: r.campus_id,
    level: r.level,
    status: r.status,
    account: r.account === undefined ? r.name : r.account,
    studentCount: r.student_count === undefined ? undefined : r.student_count,
    classCount: r.class_count === undefined ? undefined : r.class_count,
    createdAt: r.created_at,
    updatedAt: r.updated_at
  };
}

function mapAttendance(r: any) {
  return {
    id: r.id,
    teacherId: r.teacher_id,
    teacherName: r.teacher_name === undefined ? null : r.teacher_name,
    campusId: r.campus_id,
    classId: r.class_id,
    className: r.class_name,
    lessonNo: r.lesson_no,
    lessonLabel: r.lesson_label,
    durationMinutes: r.duration_minutes,
    studentCount: r.student_count,
    leaveCount: r.leave_count,
    presentNames: r.present_names,
    leaves: r.leave_json ? safeParse(r.leave_json) : [],
    auditStatus: r.audit_status,
    auditBy: r.audit_by,
    auditAt: r.audit_at,
    auditRemark: r.audit_remark,
    actualStartTime: r.actual_start_time,
    actualEndTime: r.actual_end_time,
    emailStatus: r.email_status,
    createdAt: r.created_at,
    updatedAt: r.updated_at
  };
}

function safeParse(text: string): any {
  try {
    return JSON.parse(text);
  } catch {
    return null;
  }
}

// ---------------- 账号 ----------------

async function login(request: Request, env: Env): Promise<Response> {
  const body = await readJson(request);
  const username = str(body.username);
  const password = str(body.password);
  if (!username || !password) throw new ApiError(500, '用户名或密码不能为空');

  const user = await env.DB.prepare('SELECT * FROM sys_user WHERE username = ?').bind(username).first();
  if (!user) return fail('账号或密码错误');
  if (Number(user.status) !== 1) return fail('账号已停用，请联系管理员');

  const matched = await verifyPassword(password, user.password);
  if (!matched) return fail('账号或密码错误');

  const nowSec = Math.floor(Date.now() / 1000);
  const token = await signToken(
    {
      userId: user.id,
      username: user.username,
      role: user.role,
      teacherId: user.teacher_id,
      iat: nowSec,
      exp: nowSec + JWT_TTL_SECONDS
    },
    jwtSecret(env)
  );

  return ok({ token, user: await userPayload(env, user) });
}

async function profile(request: Request, env: Env): Promise<Response> {
  const user = await currentUser(request, env);
  return ok(await userPayload(env, user));
}

async function updateProfile(request: Request, env: Env): Promise<Response> {
  const user = await currentUser(request, env);
  const body = await readJson(request);

  const nickname = body.nickname === undefined ? user.nickname : str(body.nickname);
  const avatar = body.avatar === undefined ? user.avatar : str(body.avatar);
  const phone = body.phone === undefined ? user.phone : str(body.phone);
  const email = body.email === undefined ? user.email : str(body.email);

  let name = user.name;
  let username = user.username;

  if (user.role === 'ADMIN') {
    if (body.name !== undefined && str(body.name)) name = str(body.name);
    if (body.username !== undefined && str(body.username) && str(body.username) !== user.username) {
      const other = await env.DB.prepare('SELECT id FROM sys_user WHERE username = ? AND id != ?')
        .bind(str(body.username), user.id)
        .first();
      if (other) return fail('账号已被占用');
      username = str(body.username);
    }
  }

  const now = nowStr();
  await env.DB.prepare(
    `UPDATE sys_user SET nickname = ?, avatar = ?, phone = ?, email = ?, name = ?, username = ?, updated_at = ? WHERE id = ?`
  )
    .bind(nickname, avatar, phone, email, name, username, now, user.id)
    .run();

  // 教师信息同步
  if (user.teacher_id) {
    await env.DB.prepare('UPDATE teacher SET phone = ?, email = ?, updated_at = ? WHERE id = ?')
      .bind(phone, email, now, user.teacher_id)
      .run();
  }

  const updated = await env.DB.prepare('SELECT * FROM sys_user WHERE id = ?').bind(user.id).first();
  return ok(await userPayload(env, updated));
}

async function changePassword(request: Request, env: Env): Promise<Response> {
  const body = await readJson(request);
  const oldPassword = str(body.oldPassword);
  const newPassword = str(body.newPassword);
  if (!oldPassword) throw new ApiError(500, '请输入原密码');
  if (newPassword.length < 6) throw new ApiError(500, '新密码至少 6 位');
  assertAsciiPassword(newPassword);
  if (oldPassword === newPassword) throw new ApiError(500, '新密码不能与原密码相同');

  const user = await currentUser(request, env);
  const matched = await verifyPassword(oldPassword, user.password);
  if (!matched) return fail('原密码不正确');

  const hashed = await hashPassword(newPassword);

  if (user.role === 'ADMIN') {
    await env.DB.prepare('UPDATE sys_user SET password = ?, updated_at = ? WHERE id = ?')
      .bind(hashed, nowStr(), user.id)
      .run();
    return ok({ pending: false, msg: '密码修改成功' });
  }

  await env.DB.prepare(
    `INSERT INTO password_request (user_id, username, name, new_password, status, created_at)
     VALUES (?, ?, ?, ?, 0, ?)`
  )
    .bind(user.id, user.username, user.name, hashed, nowStr())
    .run();

  return ok({ pending: true, msg: '已提交修改密码申请，等待管理员审核' });
}

// ---------------- 管理员账号 ----------------

async function createAdmin(request: Request, env: Env): Promise<Response> {
  await requireAdmin(request, env);
  const body = await readJson(request);
  const username = str(body.username);
  const password = str(body.password);
  const name = str(body.name) || username;

  if (!username) throw new ApiError(500, '请填写账号');
  if (password.length < 6) throw new ApiError(500, '密码至少 6 位');
  assertAsciiPassword(password);

  const count = await env.DB.prepare("SELECT COUNT(*) AS c FROM sys_user WHERE role = 'ADMIN'").first();
  if (Number(count.c) >= 2) return fail('管理员账号最多 2 个');

  const exists = await env.DB.prepare('SELECT id FROM sys_user WHERE username = ?').bind(username).first();
  if (exists) return fail('账号已存在');

  const now = nowStr();
  const hashed = await hashPassword(password);
  await env.DB.prepare(
    `INSERT INTO sys_user (username, password, name, nickname, avatar, role, phone, email, status, created_at, updated_at)
     VALUES (?, ?, ?, ?, ?, 'ADMIN', ?, ?, 1, ?, ?)`
  )
    .bind(username, hashed, name, str(body.nickname) || name, str(body.avatar), str(body.phone), str(body.email), now, now)
    .run();

  const user = await env.DB.prepare('SELECT * FROM sys_user WHERE username = ?').bind(username).first();
  return ok(mapUser(user));
}

async function listAdmins(request: Request, env: Env): Promise<Response> {
  await requireAdmin(request, env);
  const rows = await env.DB.prepare("SELECT * FROM sys_user WHERE role = 'ADMIN' ORDER BY id ASC").all();
  return ok((rows.results || []).map(mapUser));
}

async function updateAdmin(request: Request, env: Env): Promise<Response> {
  await requireAdmin(request, env);
  const body = await readJson(request);
  const id = intOrNull(body.id);
  if (!id) throw new ApiError(500, '缺少 id');

  const target = await env.DB.prepare("SELECT * FROM sys_user WHERE id = ? AND role = 'ADMIN'").bind(id).first();
  if (!target) return fail('管理员不存在');

  const username = body.username !== undefined && str(body.username) ? str(body.username) : target.username;
  if (username !== target.username) {
    const other = await env.DB.prepare('SELECT id FROM sys_user WHERE username = ? AND id != ?').bind(username, id).first();
    if (other) return fail('账号已被占用');
  }

  const name = body.name !== undefined && str(body.name) ? str(body.name) : target.name;
  const nickname = body.nickname === undefined ? target.nickname : str(body.nickname);
  const avatar = body.avatar === undefined ? target.avatar : str(body.avatar);
  const phone = body.phone === undefined ? target.phone : str(body.phone);
  const email = body.email === undefined ? target.email : str(body.email);
  const password = str(body.password);

  const now = nowStr();
  await env.DB.prepare(
    `UPDATE sys_user SET username = ?, name = ?, nickname = ?, avatar = ?, phone = ?, email = ?, updated_at = ? WHERE id = ?`
  )
    .bind(username, name, nickname, avatar, phone, email, now, id)
    .run();

  if (password) {
    if (password.length < 6) throw new ApiError(500, '密码至少 6 位');
    assertAsciiPassword(password);
    const hashed = await hashPassword(password);
    await env.DB.prepare('UPDATE sys_user SET password = ? WHERE id = ?').bind(hashed, id).run();
  }

  const updated = await env.DB.prepare('SELECT * FROM sys_user WHERE id = ?').bind(id).first();
  return ok(mapUser(updated));
}

// ---------------- 教师管理 ----------------

async function nextEmployeeNo(env: Env): Promise<string> {
  const row = await env.DB.prepare(
    "SELECT MAX(CAST(SUBSTR(employee_no, 2) AS INTEGER)) AS maxNo FROM teacher WHERE employee_no LIKE 'T%'"
  ).first();
  const next = Number(row && row.maxNo ? row.maxNo : 0) + 1;
  return 'T' + String(next).padStart(3, '0');
}

async function registerTeacher(request: Request, env: Env): Promise<Response> {
  await requireAdmin(request, env);
  const body = await readJson(request);
  const name = str(body.name);
  const phone = str(body.phone);
  const email = str(body.email);
  const level = str(body.level) || 'P2';
  const campusId = intOrNull(body.campusId) || 1;

  if (!name) throw new ApiError(500, '请填写教师姓名');
  if (email && !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) throw new ApiError(500, '邮箱格式不正确');

  const existsName = await env.DB.prepare('SELECT id FROM sys_user WHERE username = ?').bind(name).first();
  if (existsName) return fail('该姓名已存在，无法作为登录账号');

  const employeeNo = await nextEmployeeNo(env);
  const initialPassword = teacherInitialPassword(name);
  const now = nowStr();

  const res = await env.DB.prepare(
    `INSERT INTO teacher (name, employee_no, phone, email, campus_id, level, status, created_at, updated_at)
     VALUES (?, ?, ?, ?, ?, ?, 1, ?, ?)`
  )
    .bind(name, employeeNo, phone, email, campusId, level, now, now)
    .run();

  const teacherId = Number(res.meta.last_row_id);
  const hashed = await hashPassword(initialPassword);

  await env.DB.prepare(
    `INSERT INTO sys_user (username, password, name, nickname, role, phone, email, teacher_id, campus_id, status, created_at, updated_at)
     VALUES (?, ?, ?, ?, 'TEACHER', ?, ?, ?, ?, 1, ?, ?)`
  )
    .bind(name, hashed, name, name, phone, email, teacherId, campusId, now, now)
    .run();

  return ok({
    teacher: {
      id: teacherId,
      name,
      employeeNo,
      account: name,
      initialPassword,
      phone,
      email,
      level
    }
  });
}

async function listTeachers(url: URL, request: Request, env: Env): Promise<Response> {
  await requireAdmin(request, env);
  const rows = await env.DB.prepare(
    `SELECT t.*, u.username AS account,
            (SELECT COUNT(*) FROM class_info c WHERE c.teacher_id = t.id) AS class_count
     FROM teacher t LEFT JOIN sys_user u ON u.teacher_id = t.id
     ORDER BY t.id ASC`
  ).all();
  return ok((rows.results || []).map(mapTeacher));
}

async function updateTeacher(request: Request, env: Env): Promise<Response> {
  await requireAdmin(request, env);
  const body = await readJson(request);
  const id = intOrNull(body.id);
  if (!id) throw new ApiError(500, '缺少 id');

  const teacher = await env.DB.prepare('SELECT * FROM teacher WHERE id = ?').bind(id).first();
  if (!teacher) return fail('教师不存在');

  const name = body.name !== undefined && str(body.name) ? str(body.name) : teacher.name;
  if (name !== teacher.name) {
    const dup = await env.DB.prepare('SELECT id FROM sys_user WHERE username = ? AND teacher_id != ?').bind(name, id).first();
    if (dup) return fail('该姓名已被使用');
  }

  const phone = body.phone === undefined ? teacher.phone : str(body.phone);
  const email = body.email === undefined ? teacher.email : str(body.email);
  const level = body.level === undefined || !str(body.level) ? teacher.level : str(body.level);
  const campusId = body.campusId === undefined ? teacher.campus_id : (intOrNull(body.campusId) || teacher.campus_id);
  const status = body.status === undefined ? teacher.status : (intOrNull(body.status) ?? teacher.status);
  const now = nowStr();

  await env.DB.prepare(
    'UPDATE teacher SET name = ?, phone = ?, email = ?, level = ?, campus_id = ?, status = ?, updated_at = ? WHERE id = ?'
  )
    .bind(name, phone, email, level, campusId, status, now, id)
    .run();

  if (name !== teacher.name) {
    // 登录账号跟随姓名全称
    await env.DB.prepare('UPDATE sys_user SET username = ?, name = ?, updated_at = ? WHERE teacher_id = ?')
      .bind(name, name, now, id)
      .run();
  }
  await env.DB.prepare('UPDATE sys_user SET phone = ?, email = ?, status = ?, updated_at = ? WHERE teacher_id = ?')
    .bind(phone, email, status, now, id)
    .run();

  const updated = await env.DB.prepare('SELECT * FROM teacher WHERE id = ?').bind(id).first();
  return ok(mapTeacher(updated));
}

async function resetTeacherPassword(request: Request, env: Env): Promise<Response> {
  await requireAdmin(request, env);
  const body = await readJson(request);
  const id = intOrNull(body.id);
  if (!id) throw new ApiError(500, '缺少 id');

  const teacher = await env.DB.prepare('SELECT * FROM teacher WHERE id = ?').bind(id).first();
  if (!teacher) return fail('教师不存在');

  const password = teacherInitialPassword(teacher.name);
  const hashed = await hashPassword(password);
  await env.DB.prepare('UPDATE sys_user SET password = ?, updated_at = ? WHERE teacher_id = ?')
    .bind(hashed, nowStr(), id)
    .run();

  return ok({ password });
}

async function deleteTeacher(request: Request, env: Env): Promise<Response> {
  await requireAdmin(request, env);
  const body = await readJson(request);
  const id = intOrNull(body.id);
  if (!id) throw new ApiError(500, '缺少 id');

  const teacher = await env.DB.prepare('SELECT * FROM teacher WHERE id = ?').bind(id).first();
  if (!teacher) return fail('教师不存在');

  const att = await env.DB.prepare('SELECT COUNT(*) AS c FROM attendance WHERE teacher_id = ?').bind(id).first();
  const plans = await env.DB.prepare('SELECT COUNT(*) AS c FROM class_schedule WHERE teacher_id = ?').bind(id).first();

  // 管理员可删除所有数据：教师连同其班级、课表、打卡（含工资记录）一并删除
  await env.DB.batch([
    env.DB.prepare('DELETE FROM attendance WHERE teacher_id = ?').bind(id),
    env.DB.prepare('DELETE FROM class_schedule WHERE teacher_id = ?').bind(id),
    env.DB.prepare('DELETE FROM class_student WHERE class_id IN (SELECT id FROM class_info WHERE teacher_id = ?)').bind(id),
    env.DB.prepare('DELETE FROM class_info WHERE teacher_id = ?').bind(id),
    env.DB.prepare('DELETE FROM password_request WHERE user_id IN (SELECT id FROM sys_user WHERE teacher_id = ?)').bind(id),
    env.DB.prepare('DELETE FROM sys_user WHERE teacher_id = ?').bind(id),
    env.DB.prepare('DELETE FROM teacher WHERE id = ?').bind(id)
  ]);

  return ok({ id, name: teacher.name, removedAttendance: Number(att.c), removedSchedules: Number(plans.c) });
}

/** 删除管理员账号：只删该账号，不影响另一个管理员与其数据 */
async function deleteAdmin(request: Request, env: Env): Promise<Response> {
  const admin = await requireAdmin(request, env);
  const body = await readJson(request);
  const id = intOrNull(body.id);
  if (!id) throw new ApiError(500, '缺少 id');
  if (Number(id) === Number(admin.id)) return fail('不能删除当前登录的管理员，请先切换到另一个管理员账号再删除');

  const target = await env.DB.prepare("SELECT * FROM sys_user WHERE id = ? AND role = 'ADMIN'").bind(id).first();
  if (!target) return fail('管理员不存在');

  const count = await env.DB.prepare("SELECT COUNT(*) AS c FROM sys_user WHERE role = 'ADMIN'").first();
  if (Number(count.c) <= 1) return fail('至少保留 1 个管理员');

  await env.DB.prepare('DELETE FROM sys_user WHERE id = ?').bind(id).run();
  return ok({ id, username: target.username });
}

// ---------------- 班级 / 排课 ----------------

async function listClasses(url: URL, request: Request, env: Env): Promise<Response> {
  const user = await currentUser(request, env);
  const params: any[] = [];
  let where = '';
  if (user.role === 'TEACHER') {
    if (!user.teacher_id) return ok([]);
    where = ' WHERE c.teacher_id = ?';
    params.push(user.teacher_id);
  }

  const rows = await env.DB.prepare(
    `SELECT c.*, t.name AS teacher_name, cl.name AS classroom_name,
            (SELECT COUNT(*) FROM class_student s WHERE s.class_id = c.id) AS student_count,
            (SELECT COUNT(*) FROM attendance a WHERE a.class_id = c.id) AS done_lessons,
            (SELECT COUNT(*) FROM class_schedule sc WHERE sc.class_id = c.id) AS planned_lessons,
            (SELECT COUNT(*) FROM class_schedule sc WHERE sc.class_id = c.id AND sc.status = 0) AS pending_lessons,
            (SELECT MAX(lesson_no) FROM attendance a WHERE a.class_id = c.id) AS max_lesson_no,
            (SELECT MAX(lesson_no) FROM class_schedule sc WHERE sc.class_id = c.id) AS max_planned_no
     FROM class_info c
     LEFT JOIN teacher t ON t.id = c.teacher_id
     LEFT JOIN classroom cl ON cl.id = c.classroom_id
     ${where}
     ORDER BY c.id DESC`
  )
    .bind(...params)
    .all();

  return ok(
    (rows.results || []).map((r: any) => {
      const nextNo = Math.max(Number(r.max_lesson_no || 0), Number(r.max_planned_no || 0)) + 1;
      return {
        id: r.id,
        name: r.name,
        code: r.code,
        gradeCode: resolveGradeCode(r.grade_code, r.name),
        subject: r.subject || '',
        classType: r.class_type || '',
        classroomId: r.classroom_id || null,
        classroomName: r.classroom_name || '',
        teacherId: r.teacher_id,
        teacherName: r.teacher_name,
        campusId: r.campus_id,
        durationMinutes: r.duration_minutes,
        studentCount: r.student_count,
        doneLessons: r.done_lessons,
        plannedLessons: r.planned_lessons,
        pendingLessons: r.pending_lessons,
        nextLessonNo: nextNo,
        nextLessonLabel: makeLessonLabel(r.teacher_name, nextNo),
        createdAt: r.created_at
      };
    })
  );
}

async function createClass(request: Request, env: Env): Promise<Response> {
  await requireAdmin(request, env);
  const body = await readJson(request);
  const code = str(body.code).toUpperCase();
  const teacherId = intOrNull(body.teacherId);
  const durationMinutes = intOrNull(body.durationMinutes) || 120;
  const gradeCode = resolveGradeCode(body.gradeCode, body.gradeCode);
  const subject = str(body.subject);
  const classType = str(body.classType);
  const classroomId = intOrNull(body.classroomId);
  let students: string[] = [];

  if (!gradeCode) throw new ApiError(500, '请选择年级');
  if (!code) throw new ApiError(500, '请填写班次代码，如 D');
  if (!/^[A-Z0-9]{1,6}$/.test(code)) throw new ApiError(500, '班次代码只能用字母或数字，最多 6 位');
  if (!teacherId) throw new ApiError(500, '请选择任课教师');
  if (durationMinutes < 30 || durationMinutes > 300) throw new ApiError(500, '单节时长需在 30-300 分钟之间');

  const name = buildClassName(gradeCode, subject, classType) || str(body.name);
  if (!name) throw new ApiError(500, '请填写班级名称');

  if (Array.isArray(body.students)) {
    students = body.students.map((s: any) => str(s)).filter(Boolean);
  } else {
    students = str(body.students)
      .split(/[,，、\s\n]+/)
      .map((s) => s.trim())
      .filter(Boolean);
  }
  if (!students.length) throw new ApiError(500, '请填写学生名单');

  const teacher = await env.DB.prepare('SELECT * FROM teacher WHERE id = ?').bind(teacherId).first();
  if (!teacher) return fail('教师不存在');

  const now = nowStr();
  const res = await env.DB.prepare(
    `INSERT INTO class_info (name, code, teacher_id, campus_id, duration_minutes, grade_code, subject, class_type, classroom_id, status, created_at, updated_at)
     VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, 1, ?, ?)`
  )
    .bind(name, code, teacherId, teacher.campus_id, durationMinutes, gradeCode, subject, classType, classroomId, now, now)
    .run();

  const classId = Number(res.meta.last_row_id);
  for (let i = 0; i < students.length; i++) {
    await env.DB.prepare('INSERT INTO class_student (class_id, name, sort_no) VALUES (?, ?, ?)')
      .bind(classId, students[i], i + 1)
      .run();
  }

  return ok({ id: classId, name, code, studentCount: students.length });
}

/** 重命名班级（结构字段或手工覆盖） */
async function renameClass(request: Request, env: Env): Promise<Response> {
  await requireAdmin(request, env);
  const body = await readJson(request);
  const id = intOrNull(body.id);
  if (!id) throw new ApiError(500, '缺少班级 id');
  const cls = await env.DB.prepare('SELECT * FROM class_info WHERE id = ?').bind(id).first();
  if (!cls) return fail('班级不存在');

  const gradeCode = resolveGradeCode(body.gradeCode, body.gradeCode);
  const subject = body.subject !== undefined ? str(body.subject) : String(cls.subject || '');
  const classType = body.classType !== undefined ? str(body.classType) : String(cls.class_type || '');
  const classroomId = body.classroomId !== undefined ? intOrNull(body.classroomId) : cls.classroom_id;
  const code = body.code !== undefined ? str(body.code).toUpperCase() : cls.code;
  const finalName = body.name && str(body.name).trim()
    ? str(body.name).trim()
    : buildClassName(gradeCode || cls.grade_code || '', subject, classType) || cls.name;

  await env.DB.prepare(
    `UPDATE class_info SET name = ?, grade_code = ?, subject = ?, class_type = ?, classroom_id = ?, code = ?, updated_at = ? WHERE id = ?`
  )
    .bind(finalName, gradeCode || cls.grade_code, subject, classType, classroomId, code, nowStr(), id)
    .run();
  return ok({ id, name: finalName });
}

/** 教室 CRUD */
async function classroomList(request: Request, env: Env): Promise<Response> {
  await currentUser(request, env);
  const now = nowStr();
  const today = now.slice(0, 10);
  const rows = await env.DB.prepare('SELECT * FROM classroom WHERE status = 1 ORDER BY size, id').all();
  const lessons = await env.DB.prepare(
    `SELECT s.id, s.classroom_id, s.lesson_label, s.planned_date, s.planned_time, s.duration_minutes,
            c.name AS class_name, t.name AS teacher_name
     FROM class_schedule s
     LEFT JOIN class_info c ON c.id = s.class_id
     LEFT JOIN teacher t ON t.id = s.teacher_id
     WHERE s.classroom_id IS NOT NULL AND s.planned_date = ? AND s.status IN (0, 1)
     ORDER BY s.classroom_id ASC, s.planned_time ASC, s.id ASC`
  ).bind(today).all();

  const byRoom: Record<string, any[]> = {};
  for (const r of (lessons.results || []) as any[]) {
    const key = String(r.classroom_id);
    if (!byRoom[key]) byRoom[key] = [];
    const startAt = r.planned_date + ' ' + r.planned_time + ':00';
    const endAt = timeAddMinutes(r.planned_date + ' ' + r.planned_time, Number(r.duration_minutes || 120));
    byRoom[key].push({
      id: r.id,
      lessonLabel: r.lesson_label || '',
      className: r.class_name || '',
      teacherName: r.teacher_name || '',
      date: r.planned_date,
      time: r.planned_time,
      endTime: endAt.slice(11, 16),
      durationMinutes: Number(r.duration_minutes || 120),
      startAt,
      endAt
    });
  }

  return ok((rows.results || []).map((r: any) => {
    const todayLessons = byRoom[String(r.id)] || [];
    const currentLesson = todayLessons.find(s => s.startAt <= now && now < s.endAt) || null;
    return {
      id: r.id,
      name: r.name,
      size: r.size,
      status: r.status,
      remark: r.remark || '',
      usageStatus: currentLesson ? 'OCCUPIED' : 'FREE',
      currentLesson,
      todayLessons
    };
  }));
}

async function classroomSave(request: Request, env: Env): Promise<Response> {
  await requireAdmin(request, env);
  const body = await readJson(request);
  const id = intOrNull(body.id);
  const name = str(body.name);
  const size = (str(body.size) === 'LARGE' ? 'LARGE' : 'SMALL');
  if (!name) throw new ApiError(500, '请填写教室名称');
  const now = nowStr();
  if (id) {
    await env.DB.prepare('UPDATE classroom SET name = ?, size = ?, updated_at = ? WHERE id = ?').bind(name, size, now, id).run();
    return ok({ id });
  }
  const res = await env.DB.prepare('INSERT INTO classroom (name, size, created_at) VALUES (?, ?, ?)').bind(name, size, now).run();
  return ok({ id: Number(res.meta.last_row_id) });
}

async function classroomDelete(request: Request, env: Env): Promise<Response> {
  await requireAdmin(request, env);
  const body = await readJson(request);
  const id = intOrNull(body.id);
  if (!id) throw new ApiError(500, '缺少教室 id');
  await env.DB.prepare('UPDATE classroom SET status = 0 WHERE id = ?').bind(id).run();
  return ok({ id });
}

async function deleteClass(request: Request, env: Env): Promise<Response> {
  await requireAdmin(request, env);
  const body = await readJson(request);
  const id = intOrNull(body.id);
  if (!id) throw new ApiError(500, '缺少 id');

  const used = await env.DB.prepare('SELECT COUNT(*) AS c FROM attendance WHERE class_id = ?').bind(id).first();
  const plans = await env.DB.prepare('SELECT COUNT(*) AS c FROM class_schedule WHERE class_id = ?').bind(id).first();

  // 管理员可删除所有数据：班级连同其课表、打卡（含工资记录）一并删除
  await env.DB.batch([
    env.DB.prepare('DELETE FROM attendance WHERE class_id = ?').bind(id),
    env.DB.prepare('DELETE FROM class_schedule WHERE class_id = ?').bind(id),
    env.DB.prepare('DELETE FROM class_student WHERE class_id = ?').bind(id),
    env.DB.prepare('DELETE FROM class_info WHERE id = ?').bind(id)
  ]);
  return ok({ id, removedAttendance: Number(used.c), removedSchedules: Number(plans.c) });
}

/**
 * 更新班级学生名单（支持中途新增或退出，不用新建班级）
 * 已提交的打卡里保存了当时的人数与名单快照，因此改名单不影响历史课次与工资
 */
async function saveClassStudents(request: Request, env: Env): Promise<Response> {
  await requireAdmin(request, env);
  const body = await readJson(request);
  const classId = intOrNull(body.classId);
  if (!classId) throw new ApiError(500, '缺少班级 id');

  const cls = await env.DB.prepare('SELECT * FROM class_info WHERE id = ?').bind(classId).first();
  if (!cls) return fail('班级不存在');

  const raw: string[] = Array.isArray(body.students)
    ? body.students.map((s: any) => str(s))
    : str(body.students).split(/[,，、;；\s\n]+/);

  const names: string[] = [];
  for (const n of raw) {
    const v = str(n);
    if (v && !names.includes(v)) names.push(v);
  }
  if (!names.length) throw new ApiError(500, '班级至少保留 1 名学生');
  if (names.length > 60) throw new ApiError(500, '单个班级学生不超过 60 人');

  const oldRows = await env.DB.prepare(
    'SELECT name FROM class_student WHERE class_id = ? ORDER BY sort_no ASC, id ASC'
  )
    .bind(classId)
    .all();
  const oldNames = (oldRows.results || []).map((r: any) => String(r.name));
  const added = names.filter((n) => !oldNames.includes(n));
  const removed = oldNames.filter((n) => !names.includes(n));

  // batch 在同一事务里执行：先清空再按新顺序写入
  const stmts: any[] = [env.DB.prepare('DELETE FROM class_student WHERE class_id = ?').bind(classId)];
  names.forEach((n, i) => {
    stmts.push(env.DB.prepare('INSERT INTO class_student (class_id, name, sort_no) VALUES (?, ?, ?)').bind(classId, n, i + 1));
  });
  stmts.push(
    env.DB.prepare('UPDATE class_info SET updated_at = ? WHERE id = ?').bind(nowStr(), classId)
  );
  await env.DB.batch(stmts);

  // 名单变更只同步到「未打卡且未过期」的课次；已上过的课次保留当时名单，不随之后的新增/删除而改变
  const today = nowStr().slice(0, 10);
  await env.DB.prepare(
    `UPDATE class_schedule SET student_names = ?, updated_at = ?
     WHERE class_id = ? AND status = 0 AND planned_date >= ?`
  )
    .bind(names.join('、'), nowStr(), classId, today)
    .run();

  return ok({ classId, count: names.length, added, removed });
}

async function classDetail(url: URL, request: Request, env: Env): Promise<Response> {
  const user = await currentUser(request, env);
  const id = intOrNull(url.searchParams.get('id'));
  if (!id) throw new ApiError(500, '缺少 id');

  const cls = await env.DB.prepare(
    `SELECT c.*, t.name AS teacher_name FROM class_info c LEFT JOIN teacher t ON t.id = c.teacher_id WHERE c.id = ?`
  )
    .bind(id)
    .first();
  if (!cls) return fail('班级不存在');
  if (user.role === 'TEACHER' && Number(cls.teacher_id) !== Number(user.teacher_id)) return fail('无权查看该班级');

  const students = await env.DB.prepare('SELECT name FROM class_student WHERE class_id = ? ORDER BY sort_no ASC, id ASC')
    .bind(id)
    .all();

  const done = await env.DB.prepare('SELECT COUNT(*) AS c FROM attendance WHERE class_id = ?').bind(id).first();
  const maxDone = await env.DB.prepare('SELECT MAX(lesson_no) AS m FROM attendance WHERE class_id = ?').bind(id).first();
  const maxPlan = await env.DB.prepare('SELECT MAX(lesson_no) AS m FROM class_schedule WHERE class_id = ?').bind(id).first();
  const nextNo = Math.max(Number(maxDone?.m || 0), Number(maxPlan?.m || 0)) + 1;

  return ok({
    id: cls.id,
    name: cls.name,
    code: cls.code,
    gradeCode: resolveGradeCode(cls.grade_code, cls.name),
    teacherId: cls.teacher_id,
    teacherName: cls.teacher_name,
    durationMinutes: cls.duration_minutes,
    students: (students.results || []).map((s: any) => s.name),
    doneLessons: Number(done.c),
    nextLessonNo: nextNo,
    nextLessonLabel: makeLessonLabel(cls.teacher_name, nextNo)
  });
}

// ---------------- 套课课表 ----------------

function parseNames(v: any): string[] {
  const raw: string[] = Array.isArray(v) ? v.map((s: any) => str(s)) : str(v).split(/[,，、;；\s\n]+/);
  const out: string[] = [];
  for (const n of raw) {
    const x = str(n);
    if (x && !out.includes(x)) out.push(x);
  }
  return out;
}

function mapSchedule(r: any) {
  return {
    id: r.id,
    classId: r.class_id,
    className: r.class_name,
    teacherId: r.teacher_id,
    teacherName: r.teacher_name,
    lessonNo: r.lesson_no,
    lessonLabel: r.lesson_label,
    date: r.planned_date,
    time: r.planned_time,
    plannedAt: r.planned_date + ' ' + r.planned_time,
    durationMinutes: r.duration_minutes,
    endTime: timeAddMinutes(r.planned_date + ' ' + r.planned_time, Number(r.duration_minutes || 120)).slice(11, 16),
    classroomId: r.classroom_id || null,
    classroomName: r.classroom_name || '',
    students: r.student_names ? String(r.student_names).split('、').filter(Boolean) : [],
    status: Number(r.status),
    attendanceId: r.attendance_id,
    remark: r.remark,
    issueFlag: Number(r.issue_flag || 0),
    issueNote: r.issue_note || '',
    source: r.source || 'ADMIN',
    auditStatus: r.audit_status === undefined || r.audit_status === null ? null : Number(r.audit_status),
    auditRemark: r.audit_remark || '',
    createdAt: r.created_at
  };
}

async function listSchedule(url: URL, request: Request, env: Env): Promise<Response> {
  await requireAdmin(request, env);
  const classId = intOrNull(url.searchParams.get('classId'));
  const teacherId = intOrNull(url.searchParams.get('teacherId'));
  const status = intOrNull(url.searchParams.get('status'));
  const onlyIssue = url.searchParams.get('issue') === '1';
  const month = str(url.searchParams.get('month'));
  if (month && !/^\d{4}-(0[1-9]|1[0-2])$/.test(month)) throw new ApiError(500, '月份格式应为 YYYY-MM');

  const where: string[] = [];
  const params: any[] = [];
  if (classId !== null) { where.push('s.class_id = ?'); params.push(classId); }
  if (teacherId !== null) { where.push('s.teacher_id = ?'); params.push(teacherId); }
  if (status !== null) { where.push('s.status = ?'); params.push(status); }
  if (onlyIssue) where.push('s.issue_flag = 1');
  if (month) {
    const nextMonth = new Date(month + '-01T00:00:00Z');
    nextMonth.setUTCMonth(nextMonth.getUTCMonth() + 1);
    where.push('s.planned_date >= ?', 's.planned_date < ?');
    params.push(month + '-01', nextMonth.toISOString().slice(0, 10));
  }
  const whereSql = where.length ? ' WHERE ' + where.join(' AND ') : '';

  // 按教师分组、组内按上课时间升序，便于管理员逐人核对课次
  const rows = await env.DB.prepare(
    `SELECT s.*, c.name AS class_name, t.name AS teacher_name, cl.name AS classroom_name,
            a.audit_status, a.audit_remark
     FROM class_schedule s
     LEFT JOIN class_info c ON c.id = s.class_id
     LEFT JOIN teacher t ON t.id = s.teacher_id
     LEFT JOIN classroom cl ON cl.id = s.classroom_id
     LEFT JOIN attendance a ON a.id = s.attendance_id
     ${whereSql}
     ORDER BY t.name ASC, s.planned_date ASC, s.planned_time ASC, s.lesson_no ASC LIMIT 1000`
  )
    .bind(...params)
    .all();
  return ok((rows.results || []).map(mapSchedule));
}

/** 新增/编辑单节课次 */
async function saveSchedule(request: Request, env: Env): Promise<Response> {
  await requireAdmin(request, env);
  const body = await readJson(request);
  const id = intOrNull(body.id);
  const classId = intOrNull(body.classId);
  const date = normDate(body.date);
  const time = normTime(body.time);
  const durationMinutes = intOrNull(body.durationMinutes) || 120;
  const classroomId = intOrNull(body.classroomId);
  const students = parseNames(body.students);
  const remark = str(body.remark);
  const now = nowStr();

  if (!date) throw new ApiError(500, '请选择上课日期');
  if (!time) throw new ApiError(500, '请填写上课时间，如 18:30');
  if (durationMinutes < 30 || durationMinutes > 300) throw new ApiError(500, '单节时长需在 30-300 分钟之间');

  let teacherId: number = 0;
  let excludeIds: number[] = [];
  if (id) {
    const old = await env.DB.prepare('SELECT * FROM class_schedule WHERE id = ?').bind(id).first();
    if (!old) return fail('课次不存在');
    if (Number(old.status) === 1) return fail('该课次已打卡，不能修改；如需改动请先删除对应打卡记录');
    teacherId = Number(old.teacher_id);
    excludeIds = [id];
  } else {
    if (!classId) throw new ApiError(500, '请选择班级');
    const cls = await env.DB.prepare('SELECT * FROM class_info WHERE id = ?').bind(classId).first();
    if (!cls) return fail('班级不存在');
    teacherId = Number(cls.teacher_id);
  }

  const conflict = await detectScheduleConflict(env, teacherId, classroomId,
    [{ date, time, durationMinutes }], excludeIds);
  if (conflict) return fail(conflict);

  if (id) {
    await env.DB.prepare(
      `UPDATE class_schedule SET planned_date = ?, planned_time = ?, duration_minutes = ?,
         classroom_id = ?, student_names = ?, remark = ?, updated_at = ? WHERE id = ?`
    )
      .bind(date, time, durationMinutes, classroomId, students.join('、'), remark, now, id)
      .run();
    return ok({ id });
  }

  const cls = await env.DB.prepare(
    'SELECT c.*, t.name AS teacher_name FROM class_info c LEFT JOIN teacher t ON t.id = c.teacher_id WHERE c.id = ?'
  ).bind(classId).first();
  const maxRow = await env.DB.prepare('SELECT MAX(lesson_no) AS m FROM class_schedule WHERE class_id = ?').bind(classId).first();
  const lessonNo = Number(maxRow?.m || 0) + 1;
  const lessonLabel = makeLessonLabel(cls.teacher_name, lessonNo);
  const res = await env.DB.prepare(
    `INSERT INTO class_schedule
       (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, remark, created_at, updated_at)
     VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, 0, ?, ?, ?)`
  )
    .bind(classId, cls.teacher_id, lessonNo, lessonLabel, date, time, durationMinutes, classroomId, students.join('、'), remark, now, now)
    .run();
  return ok({ id: Number(res.meta.last_row_id), lessonNo, lessonLabel });
}

/** 批量生成套课：支持「逐周精细设置」，每周可选多天（如单周两节、双周一节） */
async function batchSchedule(request: Request, env: Env): Promise<Response> {
  await requireAdmin(request, env);
  const body = await readJson(request);
  const classId = intOrNull(body.classId);
  const startDate = normDate(body.startDate);
  const time = normTime(body.time);
  const dayTimes = parseDayTimes(body.dayTimes);
  const startLessonNo = intOrNull(body.startLessonNo);
  const durationMinutes = intOrNull(body.durationMinutes) || 120;
  const classroomId = intOrNull(body.classroomId);
  const students = parseNames(body.students);
  const remark = str(body.remark);
  const now = nowStr();

  if (!classId) throw new ApiError(500, '请选择班级');
  if (!startDate) throw new ApiError(500, '请选择开始日期');
  if (!time && !Object.keys(dayTimes).length) throw new ApiError(500, '请填写上课时间，如 18:30');
  if (startLessonNo !== null && (startLessonNo < 1 || startLessonNo > 999)) throw new ApiError(500, '起始课次需在 1-999 之间');
  if (durationMinutes < 30 || durationMinutes > 300) throw new ApiError(500, '单节时长需在 30-300 分钟之间');

  const cls = await env.DB.prepare(
    'SELECT c.*, t.name AS teacher_name FROM class_info c LEFT JOIN teacher t ON t.id = c.teacher_id WHERE c.id = ?'
  ).bind(classId).first();
  if (!cls) return fail('班级不存在');

  // weekPlan：数组下标=从开始日期所在周算起的第几周，值为该周上课日（0=周日 … 6=周六）
  const dates: string[] = [];
  if (Array.isArray(body.weekPlan)) {
    const plan = body.weekPlan as any[];
    if (!plan.length) throw new ApiError(500, '请至少设置一周的上课日');
    if (plan.length > 52) throw new ApiError(500, '最多 52 周');
    const mondayOffset = (weekdayOf(startDate) + 6) % 7; // 周一视为一周起点
    const weekStart = dateAddDays(startDate, -mondayOffset);
    plan.forEach((daysInWeek: any, weekIndex: number) => {
      const days = Array.isArray(daysInWeek) ? daysInWeek : (daysInWeek && daysInWeek.days) || [];
      const uniq = Array.from(new Set(days.map((d: any) => Number(d)).filter((d: number) => Number.isInteger(d) && d >= 0 && d <= 6))).sort();
      for (const d of uniq) {
        const off = d === 0 ? 6 : d - 1;
        const date = dateAddDays(weekStart, weekIndex * 7 + off);
        if (date >= startDate) dates.push(date); // 开始日期之前的本周课次跳过
      }
    });
    if (!dates.length) throw new ApiError(500, '请至少选择一周的上课日');
  } else {
    // 兼容旧版：每周固定一天，共 count 节
    const weekday = intOrNull(body.weekday);
    const count = intOrNull(body.count) || 0;
    if (weekday === null || weekday < 0 || weekday > 6) throw new ApiError(500, '请选择每周上课日');
    if (count < 1 || count > 52) throw new ApiError(500, '课次数量需在 1-52 之间');
    const delta = (weekday - weekdayOf(startDate) + 7) % 7;
    const first = dateAddDays(startDate, delta);
    for (let i = 0; i < count; i++) dates.push(dateAddDays(first, i * 7));
  }
  if (dates.length > 104) throw new ApiError(500, '一次最多生成 104 节课');

  dates.sort();
  const maxRow = await env.DB.prepare('SELECT MAX(lesson_no) AS m FROM class_schedule WHERE class_id = ?').bind(classId).first();
  let lessonNo = startLessonNo !== null && startLessonNo > 0 ? startLessonNo - 1 : Number(maxRow?.m || 0);

  const stmts: any[] = [];
  const created: string[] = [];
  // 手工指定起始课次时先整体校验冲突，避免批量插入到一半失败
  if (startLessonNo !== null && startLessonNo > 0) {
    const existRows = await env.DB.prepare('SELECT lesson_no FROM class_schedule WHERE class_id = ?').bind(classId).all();
    const existNos = new Set(((existRows.results || []) as any[]).map(r => Number(r.lesson_no)));
    const conflict = dates.map((d, i) => startLessonNo + i).filter(n => existNos.has(n));
    if (conflict.length) return fail('起始课次冲突：' + makeLessonLabel(cls.teacher_name, conflict[0]) + ' 已存在，请调整起始课次后重试');
  }
  // 先整体检测老师 / 教室冲突
  const preSlots: Slot[] = dates.map(d => ({
    date: d,
    time: dayTimes[String(weekdayOf(d))] || time,
    durationMinutes
  }));
  const preConflict = await detectScheduleConflict(env, Number(cls.teacher_id), classroomId, preSlots);
  if (preConflict) return fail(preConflict);
  for (const d of dates) {
    const dayTime = dayTimes[String(weekdayOf(d))] || time;
    lessonNo += 1;
    const label = makeLessonLabel(cls.teacher_name, lessonNo);
    stmts.push(
      env.DB.prepare(
        `INSERT INTO class_schedule
           (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, remark, source, created_at, updated_at)
         VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, 0, ?, 'ADMIN', ?, ?)`
      ).bind(classId, cls.teacher_id, lessonNo, label, d, dayTime, durationMinutes, classroomId, students.join('、'), remark, now, now)
    );
    created.push(label + ' ' + d + ' ' + dayTime);
  }
  await env.DB.batch(stmts);

  return ok({ count: created.length, first: created[0] || '', last: created[created.length - 1] || '' });
}

async function deleteSchedule(request: Request, env: Env): Promise<Response> {
  await requireAdmin(request, env);
  const body = await readJson(request);
  const id = intOrNull(body.id);
  if (!id) throw new ApiError(500, '缺少 id');
  await env.DB.prepare('DELETE FROM class_schedule WHERE id = ?').bind(id).run();
  return ok({ id });
}

/**
 * 修改某课次的课次号后，同班所有课次按（日期, 时间）顺序以它为锚点自动重排。
 * 例：把 11.1 设为第 7 节，则前一节 10.24 自动变为第 6 节，之后依次为第 8、9…节。
 */
async function renumberSchedule(request: Request, env: Env): Promise<Response> {
  await requireAdmin(request, env);
  const body = await readJson(request);
  const id = intOrNull(body.id);
  const lessonNo = intOrNull(body.lessonNo);
  if (!id) throw new ApiError(500, '缺少 id');
  if (!lessonNo || lessonNo < 1 || lessonNo > 999) throw new ApiError(500, '课次需在 1-999 之间');

  const anchor = await env.DB.prepare('SELECT * FROM class_schedule WHERE id = ?').bind(id).first();
  if (!anchor) return fail('课次不存在');
  const teacher = await env.DB.prepare('SELECT name FROM teacher WHERE id = ?').bind(anchor.teacher_id).first();

  const rows = await env.DB.prepare(
    'SELECT id FROM class_schedule WHERE class_id = ? ORDER BY planned_date ASC, planned_time ASC, id ASC'
  ).bind(anchor.class_id).all();
  const list = (rows.results || []) as any[];
  const idx = list.findIndex(r => Number(r.id) === id);
  if (idx < 0) return fail('课次不在该班级中');

  const firstNo = lessonNo - idx; // 第一节课的课次号
  if (firstNo < 1) return fail('该课次之前仅有 ' + idx + ' 节课，课次号最小可设为 ' + (idx + 1) + '，否则前面的课次会小于第 1 节');

  const now = nowStr();
  // (class_id, lesson_no) 有唯一约束：先整体平移到临时区，再逐行写入目标值，避免中间状态撞号
  const stmts: any[] = [
    env.DB.prepare('UPDATE class_schedule SET lesson_no = lesson_no + 100000 WHERE class_id = ?').bind(anchor.class_id),
    ...list.map((r, i) => {
      const no = firstNo + i;
      return env.DB.prepare('UPDATE class_schedule SET lesson_no = ?, lesson_label = ?, updated_at = ? WHERE id = ?')
        .bind(no, makeLessonLabel(teacher?.name, no), now, r.id);
    })
  ];
  await env.DB.batch(stmts);
  return ok({ count: list.length, firstNo, lastNo: firstNo + list.length - 1 });
}

/** 教师删除自己的课次：scope=one 删单节；scope=series 删该套课里所有未上课、未打卡的课次 */
async function teacherDeleteSchedule(request: Request, env: Env): Promise<Response> {
  const user = await currentUser(request, env);
  if (user.role !== 'TEACHER' || !user.teacher_id) throw new ApiError(401, '仅教师账号可删除自己的课次');
  const body = await readJson(request);
  const id = intOrNull(body.id);
  const scope = str(body.scope) === 'series' ? 'series' : 'one';
  if (!id) throw new ApiError(500, '缺少课次 id');

  const row = await env.DB.prepare('SELECT * FROM class_schedule WHERE id = ?').bind(id).first();
  if (!row) return fail('课次不存在');
  if (Number(row.teacher_id) !== Number(user.teacher_id)) return fail('这不是你的课次');

  if (scope === 'one') {
    if (Number(row.status) !== 0 || Number(row.attendance_id || 0)) return fail('该课次已打卡，不能删除');
    await env.DB.prepare('DELETE FROM class_schedule WHERE id = ?').bind(id).run();
    return ok({ id, count: 1 });
  }

  const list = await env.DB.prepare(
    'SELECT id FROM class_schedule WHERE class_id = ? AND teacher_id = ? AND status = 0 AND (attendance_id IS NULL OR attendance_id = 0)'
  )
    .bind(row.class_id, user.teacher_id)
    .all();
  const ids = ((list.results || []) as any[]).map((r) => Number(r.id));
  if (!ids.length) return fail('该套课没有可删除的未上课次');
  await env.DB.batch(ids.map((sid) => env.DB.prepare('DELETE FROM class_schedule WHERE id = ?').bind(sid)));
  return ok({ classId: Number(row.class_id), count: ids.length });
}

/** 课次问题说明：管理员可标注任意课次，教师只能标注自己的课次；传空说明即清除标记 */
async function setScheduleIssue(request: Request, env: Env): Promise<Response> {
  const user = await currentUser(request, env);
  const body = await readJson(request);
  const scheduleId = intOrNull(body.scheduleId);
  const note = str(body.note);
  if (!scheduleId) throw new ApiError(500, '缺少课次 id');

  const row = await env.DB.prepare('SELECT * FROM class_schedule WHERE id = ?').bind(scheduleId).first();
  if (!row) return fail('课次不存在');
  if (user.role === 'TEACHER') {
    if (!user.teacher_id || Number(row.teacher_id) !== Number(user.teacher_id)) return fail('这不是你的课次');
  } else if (user.role !== 'ADMIN') {
    throw new ApiError(401, '无权限');
  }

  const flag = note ? 1 : 0;
  await env.DB.prepare('UPDATE class_schedule SET issue_flag = ?, issue_note = ?, updated_at = ? WHERE id = ?')
    .bind(flag, note, nowStr(), scheduleId)
    .run();
  return ok({ id: scheduleId, issueFlag: flag, issueNote: note });
}

/** 教师提交排课申请 */
async function scheduleRequestCreate(request: Request, env: Env): Promise<Response> {
  const user = await currentUser(request, env);
  if (user.role !== 'TEACHER' || !user.teacher_id) throw new ApiError(500, '仅教师账号可申请排课');
  const body = await readJson(request);
  let classId = intOrNull(body.classId) || 0;
  const date = normDate(body.date);
  const time = normTime(body.time);
  const dayTimes = parseDayTimes(body.dayTimes);
  const startLessonNo = intOrNull(body.startLessonNo);
  const durationMinutes = intOrNull(body.durationMinutes) || 120;
  const classroomId = intOrNull(body.classroomId);
  const remark = str(body.remark);
  if (!time && !Object.keys(dayTimes).length) throw new ApiError(500, '请填写上课时间');
  if (startLessonNo !== null && (startLessonNo < 1 || startLessonNo > 999)) throw new ApiError(500, '起始课次需在 1-999 之间');
  if (durationMinutes < 30 || durationMinutes > 300) throw new ApiError(500, '单节时长需在 30-300 分钟之间');

  // 教师可像管理员一样自己填写班级：审核通过时先建班级再生成课次
  const isNewClass = str(body.classMode) === 'new' || !classId;
  let newName = '', newCode = '', newStudents: string[] = [];
  const newGradeCode = resolveGradeCode(body.gradeCode, '');
  const newSubject = str(body.subject);
  const newClassType = str(body.classType);
  const now = nowStr();
  if (isNewClass) {
    if (!newGradeCode) throw new ApiError(500, '请选择年级');
    newName = buildClassName(newGradeCode, newSubject, newClassType) || str(body.className);
    newCode = str(body.classCode).toUpperCase() || 'D';
    if (!newName) throw new ApiError(500, '请填写班级名称');
    if (!/^[A-Z0-9]{1,6}$/.test(newCode)) throw new ApiError(500, '班次代码只能用字母或数字，最多 6 位');
    const rawStudents: string[] = Array.isArray(body.students)
      ? body.students.map((s: any) => str(s))
      : str(body.students).split(/[,，、;；\s\n]+/);
    newStudents = Array.from(new Set(rawStudents.map(s => str(s)).filter(Boolean)));
    if (!newStudents.length) throw new ApiError(500, '请填写学生名单，至少 1 人');
    if (newStudents.length > 60) throw new ApiError(500, '单个班级学生不超过 60 人');
    classId = 0;
  } else {
    const cls = await env.DB.prepare('SELECT * FROM class_info WHERE id = ?').bind(classId).first();
    if (!cls) return fail('班级不存在');
    if (Number(cls.teacher_id) !== Number(user.teacher_id)) return fail('这不是你的班级');
  }

  // 套课：教师一次提交多节课（前端按「每周上课日 + 周数」生成日期列表）
  const rawDates = Array.isArray(body.dates) ? body.dates.map((d: any) => normDate(d)).filter(Boolean) : [];
  let dates: string[] = [];
  if (rawDates.length) {
    dates = Array.from(new Set(rawDates)).sort();
    if (dates.length > 60) throw new ApiError(500, '单次套课最多提交 60 节');
  } else if (date) {
    dates = [date];
  }
  if (!dates.length) throw new ApiError(500, '请选择上课日期');

  // 每个日期都要能取到上课时间：优先按星期取，其次用统一时间
  const dateTimes: Record<string, string> = {};
  for (const d of dates) {
    const t = dayTimes[String(weekdayOf(d))] || time;
    if (!t) {
      const wd = ['周日', '周一', '周二', '周三', '周四', '周五', '周六'][weekdayOf(d)];
      throw new ApiError(500, '请填写' + wd + '（' + d + '）的上课时间');
    }
    dateTimes[d] = t;
  }
  const firstTime = dateTimes[dates[0]];

  const res = await env.DB.prepare(
    `INSERT INTO schedule_request
       (teacher_id, class_id, planned_date, planned_time, duration_minutes, classroom_id, remark, week_dates, lesson_count,
        new_class_name, new_class_code, new_students, new_grade_code, new_subject, new_class_type, day_times, start_lesson_no, status, created_at, updated_at)
     VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 0, ?, ?)`
  )
    .bind(
      user.teacher_id, classId, dates[0], firstTime, durationMinutes, classroomId, remark,
      dates.length > 1 ? JSON.stringify(dates) : '',
      dates.length,
      newName,
      newCode,
      isNewClass ? JSON.stringify(newStudents) : '',
      newGradeCode, newSubject, newClassType,
      JSON.stringify(dateTimes),
      startLessonNo,
      now, now
    )
    .run();
  return ok({ id: Number(res.meta.last_row_id), count: dates.length, newClass: isNewClass });
}

/** 教师查看自己的排课申请 */
async function scheduleRequestMy(request: Request, env: Env): Promise<Response> {
  const user = await currentUser(request, env);
  if (!user.teacher_id) return ok([]);
  const rows = await env.DB.prepare(
    `SELECT r.*, c.name AS class_name, c.code AS class_code
     FROM schedule_request r LEFT JOIN class_info c ON c.id = r.class_id
     WHERE r.teacher_id = ? ORDER BY r.id DESC LIMIT 100`
  )
    .bind(user.teacher_id)
    .all();
  return ok((rows.results || []).map(mapScheduleRequest));
}

function mapScheduleRequest(r: any) {
  let weekDates: string[] = [];
  try { weekDates = r.week_dates ? JSON.parse(String(r.week_dates)) : []; } catch { weekDates = []; }
  if (!Array.isArray(weekDates)) weekDates = [];
  let dateTimes: Record<string, string> = {};
  try { dateTimes = r.day_times ? JSON.parse(String(r.day_times)) : {}; } catch { dateTimes = {}; }
  if (!dateTimes || typeof dateTimes !== 'object') dateTimes = {};
  return {
    id: r.id,
    teacherId: r.teacher_id,
    teacherName: r.teacher_name,
    classId: r.class_id,
    className: r.class_name || r.new_class_name,
    classCode: r.class_code || r.new_class_code,
    isNewClass: !r.class_id,
    date: r.planned_date,
    time: r.planned_time,
    durationMinutes: r.duration_minutes,
    remark: r.remark,
    weekDates,
    dateTimes,
    startLessonNo: r.start_lesson_no === null || r.start_lesson_no === undefined ? null : Number(r.start_lesson_no),
    lessonCount: Number(r.lesson_count || (weekDates.length || 1)),
    status: Number(r.status),
    auditRemark: r.audit_remark || '',
    scheduleId: r.schedule_id,
    createdAt: r.created_at
  };
}

/** 管理员：排课申请列表 */
async function scheduleRequestList(url: URL, request: Request, env: Env): Promise<Response> {
  await requireAdmin(request, env);
  const status = intOrNull(url.searchParams.get('status'));
  const whereSql = status === null ? '' : ' WHERE r.status = ?';
  const stmt = env.DB.prepare(
    `SELECT r.*, c.name AS class_name, t.name AS teacher_name
     FROM schedule_request r
     LEFT JOIN class_info c ON c.id = r.class_id
     LEFT JOIN teacher t ON t.id = r.teacher_id
     ${whereSql}
     ORDER BY r.id DESC LIMIT 200`
  );
  const rows = status === null ? await stmt.all() : await stmt.bind(status).all();
  return ok((rows.results || []).map(mapScheduleRequest));
}

/** 管理员审核排课申请：通过即生成课次 */
async function scheduleRequestAudit(request: Request, env: Env): Promise<Response> {
  const admin = await requireAdmin(request, env);
  const body = await readJson(request);
  const id = intOrNull(body.id);
  const action = str(body.action);
  const remark = str(body.auditRemark);
  if (!id) throw new ApiError(500, '缺少申请 id');
  if (action !== 'APPROVE' && action !== 'REJECT') throw new ApiError(500, 'action 仅支持 APPROVE/REJECT');

  const reqRow = await env.DB.prepare(
    'SELECT r.*, t.name AS teacher_name FROM schedule_request r LEFT JOIN teacher t ON t.id = r.teacher_id WHERE r.id = ?'
  ).bind(id).first();
  if (!reqRow) return fail('申请不存在');
  if (Number(reqRow.status) !== 0) return fail('该申请已处理，请勿重复操作');

  const now = nowStr();
  if (action === 'REJECT') {
    const res = await env.DB.prepare(
      'UPDATE schedule_request SET status = 2, audit_by = ?, audit_at = ?, audit_remark = ?, updated_at = ? WHERE id = ? AND status = 0'
    )
      .bind(admin.id, now, remark, now, id)
      .run();
    if (!res.meta.changes) return fail('该申请已被其他管理员处理');
    return ok({ id, status: 2 });
  }

  // 教师自己填写的新班级：审核通过时先建班级 + 名单，再生成课次
  let cls: any = null;
  let classId = Number(reqRow.class_id || 0);
  if (!classId) {
    const name = str(reqRow.new_class_name);
    const code = str(reqRow.new_class_code).toUpperCase();
    if (!name || !code) return fail('该申请的班级信息不完整，无法通过');
    let students: string[] = [];
    try {
      const arr = reqRow.new_students ? JSON.parse(String(reqRow.new_students)) : [];
      if (Array.isArray(arr)) students = arr.map((s: any) => str(s)).filter(Boolean);
    } catch { students = []; }
    if (!students.length) return fail('该申请缺少学生名单，无法通过');
    const teacher = await env.DB.prepare('SELECT * FROM teacher WHERE id = ?').bind(reqRow.teacher_id).first();
    const gCode = str(reqRow.new_grade_code);
    const subj = str(reqRow.new_subject);
    const cType = str(reqRow.new_class_type);
    const finalGrade = gCode ? gCode : resolveGradeCode('', name);
    const finalName = (gCode && subj && cType)
      ? buildClassName(gCode, subj, cType)
      : name;
    const ins = await env.DB.prepare(
      `INSERT INTO class_info (name, code, teacher_id, campus_id, duration_minutes, grade_code, subject, class_type, status, created_at, updated_at)
       VALUES (?, ?, ?, ?, ?, ?, ?, ?, 1, ?, ?)`
    )
      .bind(finalName, code, reqRow.teacher_id, teacher?.campus_id || null, reqRow.duration_minutes, finalGrade, subj, cType, now, now)
      .run();
    classId = Number(ins.meta.last_row_id);
    for (let i = 0; i < students.length; i++) {
      await env.DB.prepare('INSERT INTO class_student (class_id, name, sort_no) VALUES (?, ?, ?)')
        .bind(classId, students[i], i + 1)
        .run();
    }
    cls = { id: classId, code };
  } else {
    cls = await env.DB.prepare('SELECT * FROM class_info WHERE id = ?').bind(classId).first();
    if (!cls) return fail('班级已不存在，无法通过申请');
  }

  // 套课申请：一次通过即按提交的日期列表批量生成课次
  let dates: string[] = [];
  try {
    const arr = reqRow.week_dates ? JSON.parse(String(reqRow.week_dates)) : [];
    if (Array.isArray(arr)) dates = arr.map((d: any) => normDate(d)).filter(Boolean);
  } catch { dates = []; }
  if (!dates.length) dates = [reqRow.planned_date];

  let dateTimes: Record<string, string> = {};
  try {
    const obj = reqRow.day_times ? JSON.parse(String(reqRow.day_times)) : {};
    if (obj && typeof obj === 'object' && !Array.isArray(obj)) {
      for (const k of Object.keys(obj)) {
        const t = normTime(obj[k]);
        if (t) dateTimes[String(k)] = t;
      }
    }
  } catch { dateTimes = {}; }

  const maxRow = await env.DB.prepare('SELECT MAX(lesson_no) AS m FROM class_schedule WHERE class_id = ?').bind(classId).first();
  const roster = await env.DB.prepare('SELECT name FROM class_student WHERE class_id = ? ORDER BY sort_no, id').bind(classId).all();
  const rosterNames = ((roster.results || []) as any[]).map(r => String(r.name)).join('、');
  const startNo = reqRow.start_lesson_no === null || reqRow.start_lesson_no === undefined
    ? 0
    : Number(reqRow.start_lesson_no);
  let lessonNo = startNo > 0 ? startNo - 1 : Number(maxRow?.m || 0);
  const classroomId = reqRow.classroom_id ? Number(reqRow.classroom_id) : null;

  // 手工起始课次可能与已有班次号冲突，先整体校验，避免只生成一部分课次
  const existRows = await env.DB.prepare('SELECT lesson_no FROM class_schedule WHERE class_id = ?').bind(classId).all();
  const existNos = new Set(((existRows.results || []) as any[]).map(r => Number(r.lesson_no)));
  const planNos: number[] = [];
  const slots: Slot[] = [];
  for (let i = 0; i < dates.length; i++) {
    planNos.push(lessonNo + 1 + i);
    const d = dates[i];
    const t = dateTimes[d] || dateTimes[String(weekdayOf(d))] || reqRow.planned_time;
    slots.push({ date: d, time: t, durationMinutes: Number(reqRow.duration_minutes || 120) });
  }
  const conflict = planNos.filter(n => existNos.has(n));
  if (conflict.length) {
    return fail('起始课次冲突：' + makeLessonLabel(reqRow.teacher_name, conflict[0]) + ' 已存在，请调整起始课次后重试');
  }
  const preConflict = await detectScheduleConflict(env, Number(reqRow.teacher_id), classroomId, slots);
  if (preConflict) return fail(preConflict + '（来自教师申请）');

  const insertSql = `INSERT INTO class_schedule
       (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, remark, source, created_by, created_at, updated_at)
     VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, 0, ?, 'TEACHER', ?, ?, ?)`;
  const createdIds: number[] = [];
  const labels: string[] = [];
  let no = lessonNo;
  for (const d of dates) {
    no += 1;
    const label = makeLessonLabel(reqRow.teacher_name, no);
    const plannedTime = dateTimes[d] || dateTimes[String(weekdayOf(d))] || reqRow.planned_time;
    const insert = await env.DB.prepare(insertSql)
      .bind(classId, reqRow.teacher_id, no, label, d, plannedTime, reqRow.duration_minutes, classroomId, rosterNames, reqRow.remark || '', reqRow.teacher_id, now, now)
      .run();
    createdIds.push(Number(insert.meta.last_row_id));
    labels.push(label + ' ' + d);
  }
  const scheduleId = createdIds[0];

  const upd = await env.DB.prepare(
    'UPDATE schedule_request SET status = 1, class_id = ?, audit_by = ?, audit_at = ?, audit_remark = ?, schedule_id = ?, lesson_count = ?, updated_at = ? WHERE id = ? AND status = 0'
  )
    .bind(classId, admin.id, now, remark, scheduleId, createdIds.length, now, id)
    .run();
  if (!upd.meta.changes) {
    // 并发情况下另一个管理员已处理：回滚刚生成的课次（新建的班级也一并回滚）
    for (const sid of createdIds) {
      await env.DB.prepare('DELETE FROM class_schedule WHERE id = ?').bind(sid).run();
    }
    if (!Number(reqRow.class_id || 0)) {
      await env.DB.prepare('DELETE FROM class_student WHERE class_id = ?').bind(classId).run();
      await env.DB.prepare('DELETE FROM class_info WHERE id = ?').bind(classId).run();
    }
    return fail('该申请已被其他管理员处理');
  }
  return ok({ id, status: 1, classId, scheduleId, count: createdIds.length, lessonLabels: labels });
}

// ---------------- 学生名单变更申请 ----------------

function parseJsonNames(raw: any): string[] {
  try {
    const arr = raw ? JSON.parse(String(raw)) : [];
    return Array.isArray(arr) ? arr.map((s: any) => str(s)).filter(Boolean) : [];
  } catch {
    return [];
  }
}

function mapStudentRequest(r: any) {
  return {
    id: r.id,
    teacherId: r.teacher_id,
    teacherName: r.teacher_name,
    classId: r.class_id,
    className: r.class_name,
    addNames: parseJsonNames(r.add_names),
    removeNames: parseJsonNames(r.remove_names),
    reason: r.reason || '',
    status: Number(r.status),
    auditRemark: r.audit_remark || '',
    createdAt: r.created_at
  };
}

async function classRoster(env: Env, classId: number): Promise<string[]> {
  const rows = await env.DB.prepare(
    'SELECT name FROM class_student WHERE class_id = ? ORDER BY sort_no ASC, id ASC'
  )
    .bind(classId)
    .all();
  return ((rows.results || []) as any[]).map((r) => String(r.name));
}

/** 写入名单：class_student + 未来未上课课次的名单快照（已上过的课次不变） */
async function applyRoster(env: Env, classId: number, names: string[]): Promise<void> {
  const now = nowStr();
  const stmts: any[] = [env.DB.prepare('DELETE FROM class_student WHERE class_id = ?').bind(classId)];
  names.forEach((n, i) => {
    stmts.push(env.DB.prepare('INSERT INTO class_student (class_id, name, sort_no) VALUES (?, ?, ?)').bind(classId, n, i + 1));
  });
  stmts.push(env.DB.prepare('UPDATE class_info SET updated_at = ? WHERE id = ?').bind(now, classId));
  stmts.push(
    env.DB.prepare(
      `UPDATE class_schedule SET student_names = ?, updated_at = ?
       WHERE class_id = ? AND status = 0 AND planned_date >= ?`
    ).bind(names.join('、'), now, classId, now.slice(0, 10))
  );
  await env.DB.batch(stmts);
}

/** 教师提交学生名单变更申请（新增 / 移除），管理员审核后生效 */
async function studentRequestCreate(request: Request, env: Env): Promise<Response> {
  const user = await currentUser(request, env);
  if (user.role !== 'TEACHER' || !user.teacher_id) throw new ApiError(401, '仅教师账号可提交学生变更申请');
  const body = await readJson(request);
  const classId = intOrNull(body.classId);
  const reason = str(body.reason);
  const addNames = parseNames(body.addNames);
  const removeNames = parseNames(body.removeNames);
  if (!classId) throw new ApiError(500, '请选择班级');
  if (!addNames.length && !removeNames.length) throw new ApiError(500, '请填写要新增或移除的学生');

  const cls = await env.DB.prepare('SELECT * FROM class_info WHERE id = ?').bind(classId).first();
  if (!cls) return fail('班级不存在');
  if (Number(cls.teacher_id) !== Number(user.teacher_id)) return fail('这不是你的班级');

  const roster = await classRoster(env, classId);
  const already = addNames.filter((n) => roster.includes(n));
  if (already.length) return fail('这些学生已在班级中：' + already.join('、'));
  const missing = removeNames.filter((n) => !roster.includes(n));
  if (missing.length) return fail('名单中不存在：' + missing.join('、'));
  const next = roster.filter((n) => !removeNames.includes(n)).concat(addNames);
  if (!next.length) return fail('班级至少保留 1 名学生');
  if (next.length > 60) return fail('单个班级学生不超过 60 人');

  const pending = await env.DB.prepare(
    'SELECT COUNT(*) AS c FROM student_request WHERE class_id = ? AND status = 0'
  )
    .bind(classId)
    .first();
  if (Number(pending?.c || 0) > 0) return fail('该班级已有待审核的学生变更申请，请等待管理员处理');

  const now = nowStr();
  const res = await env.DB.prepare(
    `INSERT INTO student_request (teacher_id, class_id, add_names, remove_names, reason, status, created_at, updated_at)
     VALUES (?, ?, ?, ?, ?, 0, ?, ?)`
  )
    .bind(user.teacher_id, classId, JSON.stringify(addNames), JSON.stringify(removeNames), reason, now, now)
    .run();
  return ok({ id: Number(res.meta.last_row_id), addCount: addNames.length, removeCount: removeNames.length });
}

/** 教师查看自己的学生变更申请 */
async function studentRequestMy(request: Request, env: Env): Promise<Response> {
  const user = await currentUser(request, env);
  if (!user.teacher_id) return ok([]);
  const rows = await env.DB.prepare(
    `SELECT r.*, c.name AS class_name
     FROM student_request r LEFT JOIN class_info c ON c.id = r.class_id
     WHERE r.teacher_id = ? ORDER BY r.id DESC LIMIT 100`
  )
    .bind(user.teacher_id)
    .all();
  return ok((rows.results || []).map(mapStudentRequest));
}

/** 管理员：学生变更申请列表 */
async function studentRequestList(url: URL, request: Request, env: Env): Promise<Response> {
  await requireAdmin(request, env);
  const status = intOrNull(url.searchParams.get('status'));
  const whereSql = status === null ? '' : ' WHERE r.status = ?';
  const stmt = env.DB.prepare(
    `SELECT r.*, c.name AS class_name, t.name AS teacher_name
     FROM student_request r
     LEFT JOIN class_info c ON c.id = r.class_id
     LEFT JOIN teacher t ON t.id = r.teacher_id
     ${whereSql}
     ORDER BY r.id DESC LIMIT 200`
  );
  const rows = status === null ? await stmt.all() : await stmt.bind(status).all();
  return ok((rows.results || []).map(mapStudentRequest));
}

/** 管理员审核学生变更申请：通过即写入班级名单 */
async function studentRequestAudit(request: Request, env: Env): Promise<Response> {
  const admin = await requireAdmin(request, env);
  const body = await readJson(request);
  const id = intOrNull(body.id);
  const action = str(body.action);
  const remark = str(body.auditRemark);
  if (!id) throw new ApiError(500, '缺少申请 id');
  if (action !== 'APPROVE' && action !== 'REJECT') throw new ApiError(500, 'action 仅支持 APPROVE/REJECT');

  const row = await env.DB.prepare('SELECT * FROM student_request WHERE id = ?').bind(id).first();
  if (!row) return fail('申请不存在');
  if (Number(row.status) !== 0) return fail('该申请已处理，请勿重复操作');

  const now = nowStr();
  if (action === 'REJECT') {
    const res = await env.DB.prepare(
      'UPDATE student_request SET status = 2, audit_by = ?, audit_at = ?, audit_remark = ?, updated_at = ? WHERE id = ? AND status = 0'
    )
      .bind(admin.id, now, remark, now, id)
      .run();
    if (!res.meta.changes) return fail('该申请已被其他管理员处理');
    return ok({ id, status: 2 });
  }

  const cls = await env.DB.prepare('SELECT * FROM class_info WHERE id = ?').bind(row.class_id).first();
  if (!cls) return fail('班级已不存在，无法通过，请驳回该申请');

  const roster = await classRoster(env, row.class_id);
  const adds = parseJsonNames(row.add_names);
  const removes = parseJsonNames(row.remove_names);
  const missing = removes.filter((n) => !roster.includes(n));
  if (missing.length) return fail('这些学生已不在班级中：' + missing.join('、') + '，请驳回');
  const next = roster.filter((n) => !removes.includes(n));
  adds.forEach((n) => { if (!next.includes(n)) next.push(n); });
  if (!next.length) return fail('变更后班级没有学生，请驳回');
  if (next.length > 60) return fail('变更后超过 60 人，请驳回');

  await applyRoster(env, row.class_id, next);
  const upd = await env.DB.prepare(
    'UPDATE student_request SET status = 1, audit_by = ?, audit_at = ?, audit_remark = ?, updated_at = ? WHERE id = ? AND status = 0'
  )
    .bind(admin.id, now, remark, now, id)
    .run();
  if (!upd.meta.changes) {
    // 并发情况下另一位管理员已处理：恢复原名单
    await applyRoster(env, row.class_id, roster);
    return fail('该申请已被其他管理员处理');
  }
  return ok({ id, status: 1, classId: Number(row.class_id), count: next.length, added: adds, removed: removes });
}

/** 管理员：待办数量（排课申请 + 学生变更申请） */
async function pendingCounts(request: Request, env: Env): Promise<Response> {
  await requireAdmin(request, env);
  const s = await env.DB.prepare('SELECT COUNT(*) AS c FROM schedule_request WHERE status = 0').first();
  const st = await env.DB.prepare('SELECT COUNT(*) AS c FROM student_request WHERE status = 0').first();
  const schedule = Number(s?.c || 0);
  const student = Number(st?.c || 0);
  return ok({ schedule, student, total: schedule + student });
}

/** 教师端：我的课表 */
async function mySchedule(url: URL, request: Request, env: Env): Promise<Response> {
  const user = await currentUser(request, env);
  if (!user.teacher_id) return ok([]);
  const rows = await env.DB.prepare(
    `SELECT s.*, c.name AS class_name, t.name AS teacher_name, a.audit_status, a.audit_remark
     FROM class_schedule s
     LEFT JOIN class_info c ON c.id = s.class_id
     LEFT JOIN teacher t ON t.id = s.teacher_id
     LEFT JOIN attendance a ON a.id = s.attendance_id
     WHERE s.teacher_id = ? ORDER BY s.planned_date ASC, s.planned_time ASC LIMIT 300`
  )
    .bind(user.teacher_id)
    .all();
  // 课次未单独指定名单时，回落到班级当前名单
  const classIds = Array.from(new Set((rows.results || []).map((r: any) => Number(r.class_id))));
  const roster: Record<string, string[]> = {};
  for (const cid of classIds) {
    const st = await env.DB.prepare('SELECT name FROM class_student WHERE class_id = ? ORDER BY sort_no ASC, id ASC').bind(cid).all();
    roster[String(cid)] = (st.results || []).map((x: any) => String(x.name));
  }
  return ok(
    (rows.results || []).map((r: any) => {
      const m = mapSchedule(r);
      if (!m.students.length) m.students = roster[String(m.classId)] || [];
      return m;
    })
  );
}

// ---------------- 打卡 ----------------

async function submitAttendance(request: Request, env: Env, ctx: any): Promise<Response> {
  const user = await currentUser(request, env);
  if (user.role !== 'TEACHER' || !user.teacher_id) throw new ApiError(500, '仅教师账号可打卡');

  const teacher = await env.DB.prepare('SELECT * FROM teacher WHERE id = ?').bind(user.teacher_id).first();
  if (!teacher) throw new ApiError(500, '教师档案不存在');

  const body = await readJson(request);
  const classId = intOrNull(body.classId);
  const durationMinutes = intOrNull(body.durationMinutes);
  if (!classId) throw new ApiError(500, '请选择班级');
  if (durationMinutes < 30 || durationMinutes > 300) throw new ApiError(500, '单节时长需在 30-300 分钟之间');

  const cls = await env.DB.prepare('SELECT * FROM class_info WHERE id = ?').bind(classId).first();
  if (!cls) return fail('班级不存在');
  if (Number(cls.teacher_id) !== Number(user.teacher_id)) return fail('这不是你的班级');

  const present: string[] = Array.isArray(body.present) ? body.present.map((s: any) => str(s)).filter(Boolean) : [];
  const leaves: any[] = Array.isArray(body.leaves) ? body.leaves.filter((l: any) => str(l && l.name)) : [];
  if (!present.length && !leaves.length) throw new ApiError(500, '请至少勾选一名学生');
  const overlap = present.filter((n) => leaves.some((l) => str(l.name) === n));
  if (overlap.length) throw new ApiError(500, '同一学生不能同时出勤和请假: ' + overlap.join('、'));

  // 关联管理员排的课次（可选）：班次号沿用课表，上课时间默认取排课时间，教师可微调
  const scheduleId = intOrNull(body.scheduleId);
  let schedule: any = null;
  if (scheduleId) {
    schedule = await env.DB.prepare('SELECT * FROM class_schedule WHERE id = ?').bind(scheduleId).first();
    if (!schedule) return fail('课次不存在');
    if (Number(schedule.teacher_id) !== Number(user.teacher_id)) return fail('这不是你的课次');
    if (Number(schedule.class_id) !== Number(classId)) return fail('课次与班级不一致');
    if (Number(schedule.status) === 1) return fail('该课次已经打过卡了');
  }

  let lessonNo: number;
  let lessonLabel: string;
  if (schedule) {
    lessonNo = Number(schedule.lesson_no);
    lessonLabel = schedule.lesson_label || makeLessonLabel(teacher.name, lessonNo);
  } else {
    const maxRow = await env.DB.prepare('SELECT MAX(lesson_no) AS m FROM attendance WHERE class_id = ?').bind(classId).first();
    lessonNo = Number(maxRow?.m || 0) + 1;
    lessonLabel = makeLessonLabel(teacher.name, lessonNo);
  }

  const startInput = str(body.startTime);
  let start: string;
  if (startInput) {
    start = normDateTime(startInput);
    if (!start) throw new ApiError(500, '上课时间格式不正确');
  } else if (schedule) {
    start = schedule.planned_date + ' ' + schedule.planned_time + ':00';
  } else {
    start = nowStr(-durationMinutes * 60 * 1000);
  }
  const end = timeAddMinutes(start, durationMinutes);
  const cleanLeaves = leaves.map((l: any) => ({ name: str(l.name), reason: str(l.reason) }));
  const now = nowStr();

  const res = await env.DB.prepare(
    `INSERT INTO attendance
       (teacher_id, campus_id, class_id, class_name, lesson_no, lesson_label, duration_minutes,
        student_count, leave_count, present_names, leave_json, audit_status, actual_start_time, actual_end_time,
        email_status, created_at, updated_at)
     VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 0, ?, ?, '', ?, ?)`
  )
    .bind(
      teacher.id,
      teacher.campus_id,
      classId,
      cls.name,
      lessonNo,
      lessonLabel,
      durationMinutes,
      present.length,
      cleanLeaves.length,
      present.join('、'),
      JSON.stringify(cleanLeaves),
      start,
      end,
      now,
      now
    )
    .run();

  const attendanceId = Number(res.meta.last_row_id);
  if (schedule) {
    // 条件更新（仅当课次仍为待打卡）防止教师重复点击造成同一课次两条打卡
    const upd = await env.DB.prepare(
      'UPDATE class_schedule SET status = 1, attendance_id = ?, updated_at = ? WHERE id = ? AND status = 0'
    )
      .bind(attendanceId, now, schedule.id)
      .run();
    if (!upd.meta.changes) {
      await env.DB.prepare('DELETE FROM attendance WHERE id = ?').bind(attendanceId).run();
      return fail('该课次已经打过卡了，请刷新课表后重试');
    }
  }
  const row = await env.DB.prepare(
    `SELECT a.*, t.name AS teacher_name FROM attendance a LEFT JOIN teacher t ON t.id = a.teacher_id WHERE a.id = ?`
  )
    .bind(attendanceId)
    .first();
  const record = mapAttendance(row);

  // 邮件同步（不阻塞响应失败）
  const emailTask = sendAttendanceMail(env, teacher, record).catch((e: any) => {
    console.error('mail error', e);
    return '发送失败';
  });

  if (ctx && ctx.waitUntil) {
    ctx.waitUntil(
      emailTask.then(async (status: string) => {
        try {
          await env.DB.prepare('UPDATE attendance SET email_status = ? WHERE id = ?')
            .bind(status, attendanceId)
            .run();
        } catch (e) {
          console.error('email status update failed', e);
        }
      })
    );
  } else {
    const status = await emailTask;
    await env.DB.prepare('UPDATE attendance SET email_status = ? WHERE id = ?').bind(status, attendanceId).run();
    record.emailStatus = status;
  }

  return ok(record);
}

async function attendanceMy(request: Request, env: Env): Promise<Response> {
  const user = await currentUser(request, env);
  if (!user.teacher_id) return ok([]);
  const rows = await env.DB.prepare(
    `SELECT a.*, t.name AS teacher_name FROM attendance a LEFT JOIN teacher t ON t.id = a.teacher_id
     WHERE a.teacher_id = ? ORDER BY a.id DESC LIMIT 100`
  )
    .bind(user.teacher_id)
    .all();
  return ok((rows.results || []).map(mapAttendance));
}

async function attendanceList(url: URL, request: Request, env: Env): Promise<Response> {
  await requireAdmin(request, env);

  let current = intOrNull(url.searchParams.get('current')) ?? 1;
  let size = intOrNull(url.searchParams.get('size')) ?? 200;
  if (current < 1) current = 1;
  if (size < 1) size = 200;
  if (size > 1000) size = 1000;

  const where: string[] = [];
  const params: any[] = [];
  const teacherId = intOrNull(url.searchParams.get('teacherId'));
  const auditStatus = intOrNull(url.searchParams.get('auditStatus'));
  const month = str(url.searchParams.get('month'));

  if (teacherId !== null) {
    where.push('a.teacher_id = ?');
    params.push(teacherId);
  }
  if (auditStatus !== null) {
    where.push('a.audit_status = ?');
    params.push(auditStatus);
  }
  if (month) {
    where.push('a.actual_start_time LIKE ?');
    params.push(month + '%');
  }

  const whereSql = where.length ? ' WHERE ' + where.join(' AND ') : '';
  const countRow = await env.DB.prepare('SELECT COUNT(*) AS total FROM attendance a' + whereSql)
    .bind(...params)
    .first();

  const rows = await env.DB.prepare(
    `SELECT a.*, t.name AS teacher_name FROM attendance a LEFT JOIN teacher t ON t.id = a.teacher_id
     ${whereSql} ORDER BY a.id DESC LIMIT ? OFFSET ?`
  )
    .bind(...params, size, (current - 1) * size)
    .all();

  return ok({
    records: (rows.results || []).map(mapAttendance),
    total: Number(countRow?.total || 0),
    size,
    current
  });
}

async function attendanceAudit(id: number, request: Request, env: Env): Promise<Response> {
  const admin = await requireAdmin(request, env);
  const attendance = await env.DB.prepare('SELECT * FROM attendance WHERE id = ?').bind(id).first();
  if (!attendance) return fail('打卡记录不存在');
  // 防并发重复审核：两个管理员同时点「通过」时，后到的请求直接拒绝，避免重复覆盖工资快照
  if (Number(attendance.audit_status) !== 0) {
    return fail('该打卡已审核，请勿重复操作；如需修改请先删除该打卡记录后重新提交');
  }

  const body = await readJson(request);
  let action = str(body.action);
  let remark = str(body.remark);
  if (!action && body.auditStatus !== undefined) {
    action = String(body.auditStatus) === '1' ? 'APPROVE' : 'REJECT';
  }
  if (!action) throw new ApiError(500, 'action 不能为空');

  let auditStatus: number;
  if (action === 'APPROVE') auditStatus = 1;
  else if (action === 'REJECT') auditStatus = 2;
  else throw new ApiError(500, 'action 仅支持 APPROVE/REJECT');

  const now = nowStr();

  if (auditStatus === 1) {
    // 审核通过即冻结工资：写入快照，后续改费率/改学生名单都不会改变这笔工资
    // 计费优先取「该教师 + 该班级年级」的课时费，未配置时使用全局规则
    const cls = attendance.class_id
      ? await env.DB.prepare('SELECT name, grade_code FROM class_info WHERE id = ?').bind(attendance.class_id).first()
      : null;
    const gradeCode = cls ? resolveGradeCode(cls.grade_code, cls.name) : '';
    const cfg = await teacherGradeRates(env, Number(attendance.teacher_id), gradeCode);
    const hours = Number(attendance.duration_minutes) / 60;
    const pay = computePay(Number(attendance.student_count), hours, cfg);
    const teacher = await env.DB.prepare('SELECT name FROM teacher WHERE id = ?').bind(attendance.teacher_id).first();
    const res = await env.DB.prepare(
      `UPDATE attendance SET audit_status = ?, audit_by = ?, audit_at = ?, audit_remark = ?, updated_at = ?,
         pay_rule = ?, pay_unit_rate = ?, pay_hours_fee = ?, pay_head_fee = ?, pay_subtotal = ?,
         pay_teacher_name = ?, pay_snapshot_at = ? WHERE id = ? AND audit_status = 0`
    )
      .bind(
        auditStatus,
        admin.id,
        now,
        remark,
        now,
        pay.rule,
        pay.unitRate,
        pay.hoursFee,
        pay.headFee,
        pay.subtotal,
        teacher ? String(teacher.name) : '',
        now,
        id
      )
      .run();
    if (!res.meta.changes) return fail('该打卡已被其他管理员审核，请刷新后查看最新状态');
  } else {
    const res = await env.DB.prepare(
      `UPDATE attendance SET audit_status = ?, audit_by = ?, audit_at = ?, audit_remark = ?, updated_at = ?
       WHERE id = ? AND audit_status = 0`
    )
      .bind(auditStatus, admin.id, now, remark, now, id)
      .run();
    if (!res.meta.changes) return fail('该打卡已被其他管理员审核，请刷新后查看最新状态');
  }

  const row = await env.DB.prepare(
    `SELECT a.*, t.name AS teacher_name FROM attendance a LEFT JOIN teacher t ON t.id = a.teacher_id WHERE a.id = ?`
  )
    .bind(id)
    .first();
  return ok(mapAttendance(row));
}

/** 删除单条打卡（连带删除该条工资记录），对应课次恢复为「待打卡」 */
async function deleteAttendance(request: Request, env: Env): Promise<Response> {
  await requireAdmin(request, env);
  // 1月后自动禁用：测试阶段允许删除，2027-01-01 起禁止
  const now = new Date();
  const cutoff = new Date('2027-01-01T00:00:00');
  if (now >= cutoff) {
    return fail('测试阶段打卡已锁定，2027年1月起不再允许删除');
  }
  const body = await readJson(request);
  const id = intOrNull(body.id);
  if (!id) throw new ApiError(500, '缺少 id');

  const row = await env.DB.prepare('SELECT * FROM attendance WHERE id = ?').bind(id).first();
  if (!row) return fail('打卡记录不存在');

  await env.DB.batch([
    env.DB.prepare('UPDATE class_schedule SET status = 0, attendance_id = NULL, updated_at = ? WHERE attendance_id = ?').bind(nowStr(), id),
    env.DB.prepare('DELETE FROM attendance WHERE id = ?').bind(id)
  ]);
  return ok({ id, lessonLabel: row.lesson_label, className: row.class_name });
}

// ---------------- 工资 ----------------

async function salaryRates(env: Env) {
  return {
    baseRate: Number(await getSetting(env, 'salary_base_rate', '120')),
    midRate: Number(await getSetting(env, 'salary_mid_rate', '150')),
    extraPerPerson: Number(await getSetting(env, 'salary_extra_per_person', '10'))
  };
}

/** 按「教师 + 年级」取课时费，未单独配置时回落到全局规则 */
async function teacherGradeRates(env: Env, teacherId: number, gradeCode: string) {
  const global = await salaryRates(env);
  if (!teacherId || !gradeCode) return global;
  const row = await env.DB.prepare(
    'SELECT * FROM teacher_grade_rate WHERE teacher_id = ? AND grade_code = ?'
  )
    .bind(teacherId, gradeCode)
    .first();
  if (!row) return global;
  return {
    baseRate: row.base_rate === null || row.base_rate === undefined ? global.baseRate : Number(row.base_rate),
    midRate: row.mid_rate === null || row.mid_rate === undefined ? global.midRate : Number(row.mid_rate),
    extraPerPerson: row.extra_per_person === null || row.extra_per_person === undefined ? global.extraPerPerson : Number(row.extra_per_person)
  };
}

/** 按人数与时长计算课时费（1人基础、2-4人增量、5人以上按人数每小时加收） */
function computePay(count: number, hours: number, cfg: { baseRate: number; midRate: number; extraPerPerson: number }) {
  let unitRate: number;
  let rule: string;
  if (count <= 1) {
    unitRate = cfg.baseRate;
    rule = '1人成班·基础课时费';
  } else if (count <= 4) {
    unitRate = cfg.midRate;
    rule = '2-4人·增量基础课时费';
  } else {
    unitRate = cfg.midRate;
    rule = '5人以上·增量基础课时费+' + cfg.extraPerPerson + '元/人/小时';
  }
  const hoursFee = round2(unitRate * hours);
  // 超过 4 人的部分按「每人每小时」加收，半小时按半小时折算（10 元/小时 → 0.5 小时 5 元）
  const headFee = count > 4 ? round2((count - 4) * cfg.extraPerPerson * hours) : 0;
  return { unitRate, rule, hoursFee, headFee, subtotal: round2(hoursFee + headFee) };
}

async function salaryConfig(request: Request, env: Env): Promise<Response> {
  await requireAdmin(request, env);
  return ok(await salaryRates(env));
}

async function saveSalaryConfig(request: Request, env: Env): Promise<Response> {
  await requireAdmin(request, env);
  const body = await readJson(request);
  const baseRate = Number(body.baseRate);
  const midRate = Number(body.midRate);
  const extraPerPerson = Number(body.extraPerPerson);

  if (!Number.isFinite(baseRate) || baseRate < 0) throw new ApiError(500, '基础课时费不正确');
  if (!Number.isFinite(midRate) || midRate < 0) throw new ApiError(500, '增量基础课时费不正确');
  if (!Number.isFinite(extraPerPerson) || extraPerPerson < 0) throw new ApiError(500, '人头单价不正确');

  await setSetting(env, 'salary_base_rate', String(baseRate));
  await setSetting(env, 'salary_mid_rate', String(midRate));
  await setSetting(env, 'salary_extra_per_person', String(extraPerPerson));

  return ok({ baseRate, midRate, extraPerPerson });
}

async function teacherRateList(request: Request, env: Env): Promise<Response> {
  await requireAdmin(request, env);
  const teachers = await env.DB.prepare('SELECT id, name, status FROM teacher ORDER BY id').all();
  const rows = await env.DB.prepare('SELECT * FROM teacher_grade_rate').all();
  // 教师实际带课的年级，用于默认只展示相关年级
  const clsRows = await env.DB.prepare(
    `SELECT teacher_id, grade_code FROM class_info
     WHERE status = 1 AND grade_code IS NOT NULL AND grade_code <> ''
     GROUP BY teacher_id, grade_code`
  ).all();
  const byTeacher: Record<string, any> = {};
  for (const r of (rows.results || []) as any[]) {
    const key = String(r.teacher_id);
    if (!byTeacher[key]) byTeacher[key] = {};
    byTeacher[key][String(r.grade_code)] = {
      baseRate: r.base_rate === null || r.base_rate === undefined ? null : Number(r.base_rate),
      midRate: r.mid_rate === null || r.mid_rate === undefined ? null : Number(r.mid_rate)
    };
  }
  const gradesByTeacher: Record<string, string[]> = {};
  for (const r of (clsRows.results || []) as any[]) {
    const key = String(r.teacher_id);
    const g = normalizeGradeCode(r.grade_code);
    if (!g) continue;
    if (!gradesByTeacher[key]) gradesByTeacher[key] = [];
    if (gradesByTeacher[key].indexOf(g) < 0) gradesByTeacher[key].push(g);
  }
  const gradeOrder = Object.keys(GRADE_LABELS);
  for (const key of Object.keys(gradesByTeacher)) {
    gradesByTeacher[key].sort((a, b) => gradeOrder.indexOf(a) - gradeOrder.indexOf(b));
  }
  return ok({
    global: await salaryRates(env),
    grades: Object.keys(GRADE_LABELS).map(code => ({ code, name: GRADE_LABELS[code] })),
    teachers: ((teachers.results || []) as any[]).map(t => ({
      id: t.id,
      name: t.name,
      status: t.status,
      rates: byTeacher[String(t.id)] || {},
      gradeCodes: gradesByTeacher[String(t.id)] || []
    }))
  });
}

async function saveTeacherRates(request: Request, env: Env): Promise<Response> {
  await requireAdmin(request, env);
  const body = await readJson(request);
  const teacherId = intOrNull(body.teacherId);
  if (!teacherId) throw new ApiError(500, '请选择教师');
  const teacher = await env.DB.prepare('SELECT id FROM teacher WHERE id = ?').bind(teacherId).first();
  if (!teacher) throw new ApiError(500, '教师不存在');

  const rates = body.rates && typeof body.rates === 'object' ? body.rates : {};
  const stmts: any[] = [];
  const now = nowStr();
  for (const key of Object.keys(rates)) {
    const grade = normalizeGradeCode(key);
    if (!grade) continue;
    const item = rates[key] || {};
    const base = item.baseRate === '' || item.baseRate === null || item.baseRate === undefined ? null : Number(item.baseRate);
    const mid = item.midRate === '' || item.midRate === null || item.midRate === undefined ? null : Number(item.midRate);
    if (base !== null && (!Number.isFinite(base) || base < 0)) throw new ApiError(500, GRADE_LABELS[grade] + '基础课时费不正确');
    if (mid !== null && (!Number.isFinite(mid) || mid < 0)) throw new ApiError(500, GRADE_LABELS[grade] + '增量课时费不正确');
    if (base === null && mid === null) {
      stmts.push(env.DB.prepare('DELETE FROM teacher_grade_rate WHERE teacher_id = ? AND grade_code = ?').bind(teacherId, grade));
    } else {
      stmts.push(
        env.DB.prepare(
          `INSERT INTO teacher_grade_rate (teacher_id, grade_code, base_rate, mid_rate, updated_at)
           VALUES (?, ?, ?, ?, ?)
           ON CONFLICT(teacher_id, grade_code)
           DO UPDATE SET base_rate = excluded.base_rate, mid_rate = excluded.mid_rate, updated_at = excluded.updated_at`
        ).bind(teacherId, grade, base, mid, now)
      );
    }
  }
  if (stmts.length) await env.DB.batch(stmts);
  return ok({ teacherId, count: stmts.length });
}

// ---------------- 学生档案 / 套课 ----------------

function randomHexToken(bytes = 16): string {
  const arr = crypto.getRandomValues(new Uint8Array(bytes));
  return Array.from(arr).map(b => b.toString(16).padStart(2, '0')).join('');
}

/** 从打卡出勤记录统计某学生已上次数（请假与驳回不计） */
async function studentUsedLessons(env: Env, classId: any, studentName: string): Promise<number> {
  if (!classId) return 0;
  const row = await env.DB.prepare(
    `SELECT COUNT(*) AS c FROM attendance
     WHERE class_id = ? AND audit_status IN (0, 1)
       AND instr('、' || COALESCE(present_names, '') || '、', ?) > 0`
  )
    .bind(classId, '、' + studentName + '、')
    .first();
  return Number(row?.c || 0);
}

/** 汇总学生档案：套课（含已上/剩余）+ 最近上课记录（来自教师打卡） */
async function buildStudentPayload(env: Env, student: any, withContact = true, withRecords = true) {
  const courseRows = await env.DB.prepare('SELECT * FROM student_course WHERE student_id = ? ORDER BY id').bind(student.id).all();
  const courses: any[] = [];
  const records: any[] = [];

  for (const c of (courseRows.results || []) as any[]) {
    let className = '';
    let teacherId = c.teacher_id ? Number(c.teacher_id) : 0;
    if (c.class_id) {
      const cls = await env.DB.prepare('SELECT name, teacher_id FROM class_info WHERE id = ?').bind(c.class_id).first();
      if (cls) {
        className = String(cls.name || '');
        if (!teacherId) teacherId = Number(cls.teacher_id || 0);
      }
    }
    let teacherName = '';
    if (teacherId) {
      const t = await env.DB.prepare('SELECT name FROM teacher WHERE id = ?').bind(teacherId).first();
      teacherName = String(t?.name || '');
    }
    const used = await studentUsedLessons(env, c.class_id, String(student.name));
    const total = Number(c.total_lessons || 0);
    courses.push({
      id: c.id,
      classId: c.class_id,
      className,
      teacherId,
      teacherName,
      courseName: String(c.course_name || className || '未命名课程'),
      courseScope: c.course_scope === 'PACKAGE' ? 'PACKAGE' : 'SUBJECT',
      gradeCode: normalizeGradeCode(c.grade_code),
      adjustNote: String(c.adjust_note || ''),
      totalLessons: total,
      usedLessons: used,
      remainingLessons: Math.max(0, total - used)
    });

    if (c.class_id && withRecords) {
      const attRows = await env.DB.prepare(
        `SELECT id, actual_start_time, class_name, lesson_label, present_names, leave_json, audit_status
         FROM attendance
         WHERE class_id = ? AND audit_status IN (0, 1)
           AND (instr('、' || COALESCE(present_names, '') || '、', ?) > 0 OR instr(COALESCE(leave_json, ''), ?) > 0)
         ORDER BY actual_start_time DESC, id DESC LIMIT 100`
      )
        .bind(c.class_id, '、' + String(student.name) + '、', String(student.name))
        .all();
      for (const a of (attRows.results || []) as any[]) {
        const present = String(a.present_names || '').indexOf(String(student.name)) >= 0;
        records.push({
          date: String(a.actual_start_time || '').slice(0, 10),
          time: String(a.actual_start_time || '').slice(11, 16),
          className: String(a.class_name || className),
          courseName: String(c.course_name || className || ''),
          lessonLabel: String(a.lesson_label || ''),
          teacherName,
          present,
          status: present ? '已上课' : '请假'
        });
      }
    }
  }

  records.sort((a, b) => (a.date + a.time < b.date + b.time ? 1 : -1));

  const base: any = {
    id: student.id,
    name: student.name,
    gradeCode: normalizeGradeCode(student.grade_code),
    gradeName: GRADE_LABELS[normalizeGradeCode(student.grade_code)] || '',
    createdAt: student.created_at
  };
  if (withContact) {
    base.phone = student.phone || '';
    base.remark = student.remark || '';
    base.shareToken = student.share_token || '';
  }
  return { student: base, courses, records: records.slice(0, 60) };
}

async function studentList(url: URL, request: Request, env: Env): Promise<Response> {
  await requireAdmin(request, env);
  const keyword = str(url.searchParams.get('keyword'));
  const grade = normalizeGradeCode(url.searchParams.get('grade'));
  const teacherId = intOrNull(url.searchParams.get('teacherId'));

  let sql = 'SELECT DISTINCT st.* FROM student st';
  const where: string[] = ['st.status = 1'];
  const params: any[] = [];
  if (teacherId !== null) {
    sql += ' LEFT JOIN student_course sc ON sc.student_id = st.id';
    where.push('sc.teacher_id = ?');
    params.push(teacherId);
  }
  if (grade) { where.push('st.grade_code = ?'); params.push(grade); }
  if (keyword) {
    where.push('(st.name LIKE ? OR st.phone LIKE ?)');
    params.push('%' + keyword + '%', '%' + keyword + '%');
  }
  sql += ' WHERE ' + where.join(' AND ') + ' ORDER BY st.grade_code ASC, st.id DESC';
  const students = (await env.DB.prepare(sql).bind(...params).all()).results || [];

  const list: any[] = [];
  if (students.length) {
    const ids = students.map((s: any) => s.id);
    const placeholders = ids.map(() => '?').join(',');
    // 批量查套课
    const courseRows = (await env.DB.prepare(
      `SELECT * FROM student_course WHERE student_id IN (${placeholders}) ORDER BY id`
    ).bind(...ids).all()).results || [];
    const coursesByStudent: Record<number, any[]> = {};
    for (const c of courseRows as any[]) (coursesByStudent[c.student_id] ||= []).push(c);
    // 批量查班级
    const classIds = [...new Set((courseRows as any[]).map(c => c.class_id).filter(Boolean))];
    const classMap: Record<number, any> = {};
    if (classIds.length) {
      const cp = classIds.map(() => '?').join(',');
      const clsRows = (await env.DB.prepare(`SELECT id, name, teacher_id FROM class_info WHERE id IN (${cp})`).bind(...classIds).all()).results || [];
      for (const cl of clsRows as any[]) classMap[cl.id] = cl;
    }
    // 批量查教师
    const teacherIds = [...new Set([...(courseRows as any[]).map(c => c.teacher_id), ...Object.values(classMap).map((c: any) => c.teacher_id)].filter(Boolean))];
    const teacherMap: Record<number, string> = {};
    if (teacherIds.length) {
      const tp = teacherIds.map(() => '?').join(',');
      const tRows = (await env.DB.prepare(`SELECT id, name FROM teacher WHERE id IN (${tp})`).bind(...teacherIds).all()).results || [];
      for (const t of tRows as any[]) teacherMap[t.id] = String(t.name || '');
    }
    // 批量查已上课时（按班级+学生名）
    const allClassIds = [...new Set((courseRows as any[]).map(c => c.class_id).filter(Boolean))];
    const usedMap: Record<string, number> = {};
    if (allClassIds.length) {
      const ap = allClassIds.map(() => '?').join(',');
      const attRows = (await env.DB.prepare(
        `SELECT class_id, present_names FROM attendance WHERE class_id IN (${ap}) AND audit_status IN (0, 1)`
      ).bind(...allClassIds).all()).results || [];
      for (const a of attRows as any[]) {
        const names = String(a.present_names || '').split('、').filter(Boolean);
        for (const nm of names) {
          const key = a.class_id + '|' + nm;
          usedMap[key] = (usedMap[key] || 0) + 1;
        }
      }
    }

    for (const s of students as any[]) {
      const courses = (coursesByStudent[s.id] || []).map((c: any) => {
        const cls = c.class_id ? classMap[c.class_id] : null;
        const className = cls ? String(cls.name || '') : '';
        const tid = c.teacher_id || (cls ? cls.teacher_id : 0);
        const total = Number(c.total_lessons || 0);
        const used = usedMap[c.class_id + '|' + String(s.name)] || 0;
        return {
          id: c.id, classId: c.class_id, className, teacherId: tid,
          teacherName: tid ? teacherMap[tid] || '' : '',
          courseName: String(c.course_name || className || '未命名课程'),
          courseScope: c.course_scope === 'PACKAGE' ? 'PACKAGE' : 'SUBJECT',
          gradeCode: normalizeGradeCode(c.grade_code), adjustNote: String(c.adjust_note || ''),
          totalLessons: total, usedLessons: used, remainingLessons: Math.max(0, total - used)
        };
      });
      list.push({
        id: s.id, name: String(s.name || ''),
        gradeCode: normalizeGradeCode(s.grade_code),
        gradeName: GRADE_LABELS[normalizeGradeCode(s.grade_code)] || '',
        phone: String(s.phone || ''), remark: String(s.remark || ''),
        shareToken: String(s.share_token || ''), courses, records: []
      });
    }
  }
  return ok({ list, grades: Object.keys(GRADE_LABELS).map(code => ({ code, name: GRADE_LABELS[code] })) });
}

async function studentDetail(url: URL, request: Request, env: Env): Promise<Response> {
  await requireAdmin(request, env);
  const id = intOrNull(url.searchParams.get('id'));
  if (!id) throw new ApiError(500, '缺少学生 id');
  const s = await env.DB.prepare('SELECT * FROM student WHERE id = ?').bind(id).first();
  if (!s) return fail('学生不存在');
  return ok(await buildStudentPayload(env, s, true));
}

/** 学生月课表：按学生关联的班级，拉取指定月份的排课，按日期升序 */
async function studentSchedule(url: URL, request: Request, env: Env): Promise<Response> {
  await requireAdmin(request, env);
  const id = intOrNull(url.searchParams.get('id'));
  const month = str(url.searchParams.get('month'));
  if (!id) throw new ApiError(500, '缺少学生 id');
  if (!month || !/^\d{4}-(0[1-9]|1[0-2])$/.test(month)) throw new ApiError(500, '月份格式应为 YYYY-MM');

  const s = await env.DB.prepare('SELECT * FROM student WHERE id = ?').bind(id).first();
  if (!s) return fail('学生不存在');

  // 学生关联的班级（来自 student_course）
  const classRows = await env.DB.prepare(
    'SELECT class_id FROM student_course WHERE student_id = ? AND class_id IS NOT NULL GROUP BY class_id'
  ).bind(id).all();
  const classIds = (classRows.results || []).map((r: any) => Number(r.class_id)).filter(Boolean);
  if (!classIds.length) return ok({ list: [] });

  const nextMonth = new Date(month + '-01T00:00:00Z');
  nextMonth.setUTCMonth(nextMonth.getUTCMonth() + 1);
  const placeholders = classIds.map(() => '?').join(',');
  const rows = await env.DB.prepare(
    `SELECT s.*, c.name AS class_name, t.name AS teacher_name, cl.name AS classroom_name
     FROM class_schedule s
     LEFT JOIN class_info c ON c.id = s.class_id
     LEFT JOIN teacher t ON t.id = s.teacher_id
     LEFT JOIN classroom cl ON cl.id = s.classroom_id
     WHERE s.class_id IN (${placeholders})
       AND s.planned_date >= ? AND s.planned_date < ?
       AND s.status IN (0, 1)
     ORDER BY s.planned_date ASC, s.planned_time ASC, s.lesson_no ASC`
  )
    .bind(...classIds, month + '-01', nextMonth.toISOString().slice(0, 10))
    .all();
  return ok({ student: { id: s.id, name: s.name, gradeName: GRADE_LABELS[normalizeGradeCode(s.grade_code)] || '' }, list: (rows.results || []).map(mapSchedule) });
}

async function studentSave(request: Request, env: Env): Promise<Response> {
  await requireAdmin(request, env);
  const body = await readJson(request);
  const id = intOrNull(body.id);
  const name = str(body.name);
  if (!name) throw new ApiError(500, '请填写学生姓名');
  const gradeCode = resolveGradeCode(body.gradeCode, body.gradeCode);
  const phone = str(body.phone);
  const remark = str(body.remark);
  const now = nowStr();
  if (id) {
    const exist = await env.DB.prepare('SELECT * FROM student WHERE id = ?').bind(id).first();
    if (!exist) return fail('学生不存在');
    await env.DB.prepare(
      'UPDATE student SET name = ?, grade_code = ?, phone = ?, remark = ?, share_token = COALESCE(NULLIF(share_token, \'\'), ?), updated_at = ? WHERE id = ?'
    )
      .bind(name, gradeCode, phone, remark, exist.share_token || randomHexToken(), now, id)
      .run();
    return ok({ id });
  }
  const res = await env.DB.prepare(
    'INSERT INTO student (name, grade_code, phone, remark, share_token, status, created_at, updated_at) VALUES (?, ?, ?, ?, ?, 1, ?, ?)'
  )
    .bind(name, gradeCode, phone, remark, randomHexToken(), now, now)
    .run();
  return ok({ id: Number(res.meta.last_row_id) });
}

async function studentDelete(request: Request, env: Env): Promise<Response> {
  await requireAdmin(request, env);
  const body = await readJson(request);
  const id = intOrNull(body.id);
  if (!id) throw new ApiError(500, '缺少学生 id');
  await env.DB.batch([
    env.DB.prepare('DELETE FROM student_course WHERE student_id = ?').bind(id),
    env.DB.prepare('DELETE FROM student WHERE id = ?').bind(id)
  ]);
  return ok({ id });
}

async function studentCourseSave(request: Request, env: Env): Promise<Response> {
  await requireAdmin(request, env);
  const body = await readJson(request);
  const id = intOrNull(body.id);
  const studentId = intOrNull(body.studentId);
  if (!studentId) throw new ApiError(500, '请选择学生');
  const s = await env.DB.prepare('SELECT * FROM student WHERE id = ?').bind(studentId).first();
  if (!s) return fail('学生不存在');
  const classId = intOrNull(body.classId);
  let className = '';
  let teacherId = intOrNull(body.teacherId);
  if (classId) {
    const cls = await env.DB.prepare('SELECT name, teacher_id, grade_code FROM class_info WHERE id = ?').bind(classId).first();
    if (!cls) return fail('班级不存在');
    className = String(cls.name || '');
    if (!teacherId) teacherId = Number(cls.teacher_id || 0) || null;
  }
  const courseName = str(body.courseName) || className;
  if (!courseName) throw new ApiError(500, '请填写课程名称或选择班级');
  const totalLessons = intOrNull(body.totalLessons);
  if (totalLessons === null || totalLessons < 0 || totalLessons > 999) throw new ApiError(500, '总课时需在 0-999 之间');
  const courseScope = str(body.courseScope) === 'PACKAGE' ? 'PACKAGE' : 'SUBJECT';
  const gradeCode = normalizeGradeCode(body.gradeCode) || resolveGradeCode('', className);
  const now = nowStr();
  if (id) {
    await env.DB.prepare(
      'UPDATE student_course SET class_id = ?, teacher_id = ?, course_name = ?, total_lessons = ?, course_scope = ?, grade_code = ?, updated_at = ? WHERE id = ? AND student_id = ?'
    )
      .bind(classId, teacherId, courseName, totalLessons, courseScope, gradeCode, now, id, studentId)
      .run();
    return ok({ id });
  }
  const res = await env.DB.prepare(
    'INSERT INTO student_course (student_id, class_id, teacher_id, course_name, total_lessons, course_scope, grade_code, created_at, updated_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)'
  )
    .bind(studentId, classId, teacherId, courseName, totalLessons, courseScope, gradeCode, now, now)
    .run();
  return ok({ id: Number(res.meta.last_row_id) });
}

/** 对学生套课做增补或退课（增减总课时） */
async function studentCourseAdjust(request: Request, env: Env): Promise<Response> {
  await requireAdmin(request, env);
  const body = await readJson(request);
  const id = intOrNull(body.id);
  if (!id) throw new ApiError(500, '缺少套课 id');
  const delta = Number(body.delta);
  if (!Number.isFinite(delta) || delta <= 0 || delta > 999) throw new ApiError(500, '节数需在 1-999 之间');
  const course = await env.DB.prepare('SELECT * FROM student_course WHERE id = ?').bind(id).first();
  if (!course) return fail('套课不存在');
  const current = Number(course.total_lessons || 0);
  const newTotal = str(body.type) === 'REFUND' ? current - delta : current + delta;
  if (newTotal < 0) throw new ApiError(500, '退课后总课时不能为负数（当前剩余 = ' + current + '）');
  const now = nowStr();
  await env.DB.prepare('UPDATE student_course SET total_lessons = ?, adjust_note = ?, updated_at = ? WHERE id = ?')
    .bind(newTotal, (str(body.type) === 'REFUND' ? '退课' : '增补') + ' ' + delta + ' 节；' + str(body.note), now, id)
    .run();
  return ok({ id, totalLessons: newTotal });
}

async function studentCourseDelete(request: Request, env: Env): Promise<Response> {
  await requireAdmin(request, env);
  const body = await readJson(request);
  const id = intOrNull(body.id);
  if (!id) throw new ApiError(500, '缺少套课 id');
  await env.DB.prepare('DELETE FROM student_course WHERE id = ?').bind(id).run();
  return ok({ id });
}

async function studentRegenerateToken(request: Request, env: Env): Promise<Response> {
  await requireAdmin(request, env);
  const body = await readJson(request);
  const id = intOrNull(body.id);
  if (!id) throw new ApiError(500, '缺少学生 id');
  const token = randomHexToken();
  await env.DB.prepare('UPDATE student SET share_token = ?, updated_at = ? WHERE id = ?').bind(token, nowStr(), id).run();
  return ok({ id, shareToken: token });
}

/** 公开分享：学生家长免登录查看上课记录与剩余课时 */
async function publicStudent(url: URL, env: Env): Promise<Response> {
  const token = str(url.searchParams.get('token'));
  if (!token) return fail('缺少分享码', 400);
  const s = await env.DB.prepare('SELECT * FROM student WHERE share_token = ? AND status = 1').bind(token).first();
  if (!s) return fail('分享链接无效或已失效', 404);
  return ok(await buildStudentPayload(env, s, false));
}

async function buildSalaryReport(env: Env, month: string, day?: string): Promise<any> {
  const cfg = await salaryRates(env);

  const prefix = day || month;
  const rows = await env.DB.prepare(
    `SELECT a.*, COALESCE(NULLIF(a.pay_teacher_name, ''), t.name) AS teacher_name,
            c.name AS cls_name, c.grade_code AS cls_grade
     FROM attendance a
     LEFT JOIN teacher t ON t.id = a.teacher_id
     LEFT JOIN class_info c ON c.id = a.class_id
     WHERE a.audit_status = 1 AND a.actual_start_time LIKE ?
     ORDER BY a.teacher_id ASC, a.actual_start_time ASC, a.id ASC`
  )
    .bind(prefix + '%')
    .all();

  const details: any[] = [];
  for (const r of (rows.results || []) as any[]) {
    const hours = Number(r.duration_minutes) / 60;
    const count = Number(r.student_count);
    // 审核通过时已冻结工资，之后改费率/改名单都不影响历史金额
    const frozen = r.pay_subtotal !== null && r.pay_subtotal !== undefined;
    let pay: any;
    if (frozen) {
      pay = {
        unitRate: Number(r.pay_unit_rate),
        rule: String(r.pay_rule || ''),
        hoursFee: Number(r.pay_hours_fee),
        headFee: Number(r.pay_head_fee),
        subtotal: Number(r.pay_subtotal)
      };
    } else {
      const gradeCode = resolveGradeCode(r.cls_grade, r.cls_name || r.class_name);
      const rowCfg = await teacherGradeRates(env, Number(r.teacher_id), gradeCode);
      pay = computePay(count, hours, rowCfg);
    }
    details.push({
      id: r.id,
      teacherId: r.teacher_id,
      teacherName: r.teacher_name,
      className: r.class_name,
      lessonLabel: r.lesson_label,
      date: String(r.actual_start_time || '').slice(0, 10),
      hours,
      studentCount: count,
      leaveCount: Number(r.leave_count),
      rule: pay.rule,
      unitRate: pay.unitRate,
      hoursFee: pay.hoursFee,
      headFee: pay.headFee,
      subtotal: pay.subtotal
    });
  }

  const summaryMap: Record<string, any> = {};
  for (const d of details) {
    const key = String(d.teacherId);
    if (!summaryMap[key]) {
      summaryMap[key] = { teacherId: d.teacherId, teacherName: d.teacherName, lessons: 0, hours: 0, amount: 0 };
    }
    summaryMap[key].lessons += 1;
    summaryMap[key].hours = round2(summaryMap[key].hours + d.hours);
    summaryMap[key].amount = round2(summaryMap[key].amount + d.subtotal);
  }

  return {
    month,
    day: day || '',
    config: cfg,
    details,
    summary: Object.values(summaryMap),
    totalAmount: round2(details.reduce((s, d) => s + d.subtotal, 0))
  };
}

function dayParam(url: URL): string {
  const d = str(url.searchParams.get('date'));
  return /^\d{4}-\d{2}-\d{2}$/.test(d) ? d : '';
}

async function salaryReport(url: URL, request: Request, env: Env): Promise<Response> {
  await requireAdmin(request, env);
  const month = str(url.searchParams.get('month')) || nowStr().slice(0, 7);
  return ok(await buildSalaryReport(env, month, dayParam(url)));
}

// ---------------- 工资 Excel 导出（原生 xlsx，无外部依赖） ----------------

const CRC_TABLE = (() => {
  const t = new Uint32Array(256);
  for (let n = 0; n < 256; n++) {
    let c = n;
    for (let k = 0; k < 8; k++) c = c & 1 ? 0xEDB88320 ^ (c >>> 1) : c >>> 1;
    t[n] = c >>> 0;
  }
  return t;
})();

function crc32(data: Uint8Array): number {
  let c = 0xFFFFFFFF;
  for (let i = 0; i < data.length; i++) c = CRC_TABLE[(c ^ data[i]) & 0xFF] ^ (c >>> 8);
  return (c ^ 0xFFFFFFFF) >>> 0;
}

function zipStore(files: { name: string; data: Uint8Array }[]): Uint8Array {
  const chunks: Uint8Array[] = [];
  const central: Uint8Array[] = [];
  let offset = 0;
  const dosTime = 0;
  const dosDate = ((2026 - 1980) << 9) | (1 << 5) | 1;

  for (const f of files) {
    const nameBytes = enc.encode(f.name);
    const crc = crc32(f.data);

    const local = new Uint8Array(30 + nameBytes.length);
    const lv = new DataView(local.buffer);
    lv.setUint32(0, 0x04034b50, true);
    lv.setUint16(4, 20, true);
    lv.setUint16(6, 0x0800, true);
    lv.setUint16(8, 0, true);
    lv.setUint16(10, dosTime, true);
    lv.setUint16(12, dosDate, true);
    lv.setUint32(14, crc, true);
    lv.setUint32(18, f.data.length, true);
    lv.setUint32(22, f.data.length, true);
    lv.setUint16(26, nameBytes.length, true);
    lv.setUint16(28, 0, true);
    local.set(nameBytes, 30);
    chunks.push(local, f.data);

    const cen = new Uint8Array(46 + nameBytes.length);
    const cv = new DataView(cen.buffer);
    cv.setUint32(0, 0x02014b50, true);
    cv.setUint16(4, 20, true);
    cv.setUint16(6, 20, true);
    cv.setUint16(8, 0x0800, true);
    cv.setUint16(10, 0, true);
    cv.setUint16(12, dosTime, true);
    cv.setUint16(14, dosDate, true);
    cv.setUint32(16, crc, true);
    cv.setUint32(20, f.data.length, true);
    cv.setUint32(24, f.data.length, true);
    cv.setUint16(28, nameBytes.length, true);
    cv.setUint32(42, offset, true);
    cen.set(nameBytes, 46);
    central.push(cen);

    offset += local.length + f.data.length;
  }

  const centralSize = central.reduce((s, c) => s + c.length, 0);
  const end = new Uint8Array(22);
  const ev = new DataView(end.buffer);
  ev.setUint32(0, 0x06054b50, true);
  ev.setUint16(8, files.length, true);
  ev.setUint16(10, files.length, true);
  ev.setUint32(12, centralSize, true);
  ev.setUint32(16, offset, true);

  const out = new Uint8Array(offset + centralSize + 22);
  let p = 0;
  for (const c of chunks.concat(central)) {
    out.set(c, p);
    p += c.length;
  }
  out.set(end, p);
  return out;
}

function xmlEsc(v: any): string {
  return String(v == null ? '' : v)
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/[\x00-\x08\x0B\x0C\x0E-\x1F]/g, '');
}

function colName(n: number): string {
  let s = '';
  while (n > 0) {
    const m = (n - 1) % 26;
    s = String.fromCharCode(65 + m) + s;
    n = Math.floor((n - 1) / 26);
  }
  return s;
}

type SheetCell = string | number | null | { text: string; style?: number };

function sheetXml(rows: SheetCell[][], widths: number[]): string {
  let body = '';
  rows.forEach((row, ri) => {
    body += '<row r="' + (ri + 1) + '">';
    row.forEach((cell, ci) => {
      if (cell === null || cell === undefined || cell === '') return;
      const ref = colName(ci + 1) + (ri + 1);
      if (typeof cell === 'number' && isFinite(cell)) {
        body += '<c r="' + ref + '" s="1"><v>' + cell + '</v></c>';
      } else if (typeof cell === 'object') {
        body += '<c r="' + ref + '" s="' + (cell.style || 1) + '" t="inlineStr"><is><t>' + xmlEsc(cell.text) + '</t></is></c>';
      } else {
        body += '<c r="' + ref + '" s="' + (ri === 0 ? 2 : 1) + '" t="inlineStr"><is><t>' + xmlEsc(cell) + '</t></is></c>';
      }
    });
    body += '</row>';
  });
  const cols = '<cols>' + widths.map((w, i) => '<col min="' + (i + 1) + '" max="' + (i + 1) + '" width="' + w + '" customWidth="1"/>').join('') + '</cols>';
  return '<?xml version="1.0" encoding="UTF-8" standalone="yes"?><worksheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main">' + cols + '<sheetData>' + body + '</sheetData></worksheet>';
}

function buildSalaryXlsx(data: any): Uint8Array {
  const detailRows: SheetCell[][] = [
    ['月份', '教师', '班级', '班次', '日期（年月日）', '时长(小时)', '到课人数', '请假人数', '适用规则', '单价(元/小时)', '课时费(元)', '人数费(元)', '小计(元)']
  ];
  let groupName = '';
  let gLessons = 0, gHours = 0, gHoursFee = 0, gHeadFee = 0, gSubtotal = 0;
  const flushGroup = () => {
    if (!groupName) return;
    detailRows.push([
      { text: groupName + ' 小计（' + gLessons + ' 次课 / ' + round2(gHours) + ' 小时）', style: 2 },
      '', '', '', '', round2(gHours), '', '', '', '',
      round2(gHoursFee), round2(gHeadFee), round2(gSubtotal)
    ]);
    groupName = '';
    gLessons = 0; gHours = 0; gHoursFee = 0; gHeadFee = 0; gSubtotal = 0;
  };
  for (const d of data.details) {
    if (d.teacherName !== groupName) {
      flushGroup();
      groupName = d.teacherName;
    }
    gLessons += 1;
    gHours += d.hours;
    gHoursFee += d.hoursFee;
    gHeadFee += d.headFee;
    gSubtotal += d.subtotal;
    detailRows.push([
      data.month, d.teacherName, d.className || '', d.lessonLabel || '', d.date,
      d.hours, d.studentCount, d.leaveCount, d.rule, d.unitRate, d.hoursFee, d.headFee, d.subtotal
    ]);
  }
  flushGroup();
  detailRows.push([
    { text: '合计', style: 2 }, '', '', '', '', '', '', '', '', '',
    round2(data.details.reduce((s: number, d: any) => s + d.hoursFee, 0)),
    round2(data.details.reduce((s: number, d: any) => s + d.headFee, 0)),
    data.totalAmount
  ]);

  const summaryRows: SheetCell[][] = [
    ['教师', '课次', '总时长(小时)', '应发工资(元)']
  ];
  let totalLessons = 0;
  let totalHours = 0;
  for (const s of data.summary) {
    summaryRows.push([s.teacherName, s.lessons, s.hours, s.amount]);
    totalLessons += s.lessons;
    totalHours = round2(totalHours + s.hours);
  }
  summaryRows.push([{ text: '合计', style: 2 }, totalLessons, totalHours, data.totalAmount]);
  summaryRows.push([]);
  summaryRows.push(['计费规则', '']);
  summaryRows.push(['1 人成班', data.config.baseRate + ' 元/小时']);
  summaryRows.push(['2-4 人', data.config.midRate + ' 元/小时']);
  summaryRows.push(['5 人以上', '增量基础课时费 + (人数-4) × ' + data.config.extraPerPerson + ' 元/人/小时']);
  summaryRows.push(['统计范围', data.day ? data.day + '（单日）' : data.month + '（整月）']);
  summaryRows.push(['导出时间', nowStr()]);

  const files = [
    {
      name: '[Content_Types].xml',
      data: enc.encode('<?xml version="1.0" encoding="UTF-8" standalone="yes"?><Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types"><Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/><Default Extension="xml" ContentType="application/xml"/><Override PartName="/xl/workbook.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet.main+xml"/><Override PartName="/xl/worksheets/sheet1.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.worksheet+xml"/><Override PartName="/xl/worksheets/sheet2.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.worksheet+xml"/><Override PartName="/xl/styles.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.styles+xml"/></Types>')
    },
    {
      name: '_rels/.rels',
      data: enc.encode('<?xml version="1.0" encoding="UTF-8" standalone="yes"?><Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships"><Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="xl/workbook.xml"/></Relationships>')
    },
    {
      name: 'xl/workbook.xml',
      data: enc.encode('<?xml version="1.0" encoding="UTF-8" standalone="yes"?><workbook xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"><sheets><sheet name="工资明细" sheetId="1" r:id="rId1"/><sheet name="教师汇总" sheetId="2" r:id="rId2"/></sheets></workbook>')
    },
    {
      name: 'xl/_rels/workbook.xml.rels',
      data: enc.encode('<?xml version="1.0" encoding="UTF-8" standalone="yes"?><Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships"><Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/worksheet" Target="worksheets/sheet1.xml"/><Relationship Id="rId2" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/worksheet" Target="worksheets/sheet2.xml"/><Relationship Id="rId3" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/styles" Target="styles.xml"/></Relationships>')
    },
    {
      name: 'xl/styles.xml',
      data: enc.encode('<?xml version="1.0" encoding="UTF-8" standalone="yes"?><styleSheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main"><fonts count="2"><font><sz val="11"/><name val="宋体"/></font><font><b/><sz val="11"/><name val="宋体"/></font></fonts><fills count="3"><fill><patternFill patternType="none"/></fill><fill><patternFill patternType="gray125"/></fill><fill><patternFill patternType="solid"><fgColor rgb="FFE8EEFB"/><bgColor indexed="64"/></patternFill></fill></fills><borders count="2"><border/><border><left style="thin"><color rgb="FFD0D7E5"/></left><right style="thin"><color rgb="FFD0D7E5"/></right><top style="thin"><color rgb="FFD0D7E5"/></top><bottom style="thin"><color rgb="FFD0D7E5"/></bottom></border></borders><cellStyleXfs count="1"><xf numFmtId="0" fontId="0" fillId="0" borderId="0"/></cellStyleXfs><cellXfs count="3"><xf numFmtId="0" fontId="0" fillId="0" borderId="0" xfId="0"/><xf numFmtId="0" fontId="0" fillId="0" borderId="1" xfId="0" applyBorder="1"/><xf numFmtId="0" fontId="1" fillId="2" borderId="1" xfId="0" applyFont="1" applyFill="1" applyBorder="1"/></cellXfs><cellStyles count="1"><cellStyle name="Normal" xfId="0" builtinId="0"/></cellStyles></styleSheet>')
    },
    {
      name: 'xl/worksheets/sheet1.xml',
      data: enc.encode(sheetXml(detailRows, [10, 12, 22, 8, 12, 12, 10, 10, 30, 14, 12, 12, 12]))
    },
    {
      name: 'xl/worksheets/sheet2.xml',
      data: enc.encode(sheetXml(summaryRows, [14, 10, 14, 16]))
    }
  ];

  return zipStore(files);
}

async function salaryExport(url: URL, request: Request, env: Env): Promise<Response> {
  await requireAdmin(request, env);
  const month = str(url.searchParams.get('month')) || nowStr().slice(0, 7);
  const day = dayParam(url);
  const data = await buildSalaryReport(env, month, day);
  const zip = buildSalaryXlsx(data);
  const suffix = day || month;

  return new Response(zip as any, {
    status: 200,
    headers: {
      'content-type': 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      'content-disposition': 'attachment; filename="salary-' + suffix + '.xlsx"',
      'access-control-allow-origin': '*',
      'cache-control': 'no-store'
    }
  });
}

function round2(n: number): number {
  return Math.round(n * 100) / 100;
}

// ---------------- 修改密码审核 ----------------

async function passwordRequests(url: URL, request: Request, env: Env): Promise<Response> {
  await requireAdmin(request, env);
  const status = intOrNull(url.searchParams.get('status'));
  const rows =
    status === null
      ? await env.DB.prepare('SELECT id, user_id, username, name, status, remark, reviewed_by, reviewed_at, created_at FROM password_request ORDER BY id DESC LIMIT 100').all()
      : await env.DB.prepare('SELECT id, user_id, username, name, status, remark, reviewed_by, reviewed_at, created_at FROM password_request WHERE status = ? ORDER BY id DESC LIMIT 100').bind(status).all();
  return ok(rows.results || []);
}

async function reviewPasswordRequest(request: Request, env: Env): Promise<Response> {
  const admin = await requireAdmin(request, env);
  const body = await readJson(request);
  const id = intOrNull(body.id);
  const action = str(body.action);
  if (!id) throw new ApiError(500, '缺少 id');
  if (action !== 'APPROVE' && action !== 'REJECT') throw new ApiError(500, 'action 仅支持 APPROVE/REJECT');

  const reqRow = await env.DB.prepare('SELECT * FROM password_request WHERE id = ?').bind(id).first();
  if (!reqRow) return fail('申请不存在');
  if (Number(reqRow.status) !== 0) return fail('该申请已处理');

  const now = nowStr();
  if (action === 'APPROVE') {
    await env.DB.prepare('UPDATE sys_user SET password = ?, updated_at = ? WHERE id = ?')
      .bind(reqRow.new_password, now, reqRow.user_id)
      .run();
  }

  await env.DB.prepare(
    'UPDATE password_request SET status = ?, remark = ?, reviewed_by = ?, reviewed_at = ? WHERE id = ?'
  )
    .bind(action === 'APPROVE' ? 1 : 2, str(body.remark), admin.username, now, id)
    .run();

  return ok({ id, status: action === 'APPROVE' ? 1 : 2 });
}

// ---------------- 邮件 ----------------

async function mailSettings(request: Request, env: Env): Promise<Response> {
  await requireAdmin(request, env);
  if (request.method === 'GET') {
    return ok({
      apiKey: await getSetting(env, 'mail_api_key'),
      fromEmail: await getSetting(env, 'mail_from_email'),
      fromName: await getSetting(env, 'mail_from_name', '教师工资统计系统')
    });
  }
  const body = await readJson(request);
  await setSetting(env, 'mail_api_key', str(body.apiKey));
  await setSetting(env, 'mail_from_email', str(body.fromEmail));
  await setSetting(env, 'mail_from_name', str(body.fromName) || '教师工资统计系统');
  return ok({ saved: true });
}

async function mailLogs(request: Request, env: Env): Promise<Response> {
  await requireAdmin(request, env);
  const rows = await env.DB.prepare('SELECT * FROM email_log ORDER BY id DESC LIMIT 100').all();
  return ok(rows.results || []);
}

function buildWordHtml(teacher: any, record: any): string {
  const leaves = record.leaves || [];
  const leaveRows = leaves.length
    ? leaves.map((l: any) => `<tr><td>${esc(l.name)}</td><td>${esc(l.reason || '未填写')}</td></tr>`).join('')
    : '<tr><td colspan="2">无</td></tr>';

  return `<html xmlns:o="urn:schemas-microsoft-com:office:office" xmlns:w="urn:schemas-microsoft-com:office:word" xmlns="http://www.w3.org/TR/REC-html40">
<head><meta charset="utf-8"><title>上课打卡记录</title>
<style>
body{font-family:"Microsoft YaHei",Arial,sans-serif;font-size:12pt;color:#333}
h1{font-size:18pt;text-align:center}
table{border-collapse:collapse;width:100%;margin:8pt 0}
td,th{border:1px solid #999;padding:6pt;font-size:11pt}
th{background:#f2f2f2}
</style></head><body>
<h1>上课打卡记录</h1>
<table>
<tr><th style="width:30%">教师</th><td>${esc(teacher.name)}（工号 ${esc(teacher.employee_no)}）</td></tr>
<tr><th>班级</th><td>${esc(record.className)}</td></tr>
<tr><th>班次</th><td>${esc(record.lessonLabel)}（第 ${esc(record.lessonNo)} 次课）</td></tr>
<tr><th>上课时间</th><td>${esc(record.actualStartTime)} — ${esc(record.actualEndTime)}</td></tr>
<tr><th>时长</th><td>${(Number(record.durationMinutes) / 60).toFixed(1)} 小时</td></tr>
<tr><th>到课人数</th><td>${esc(record.studentCount)} 人</td></tr>
<tr><th>出勤名单</th><td>${esc(record.presentNames || '无')}</td></tr>
<tr><th>请假人数</th><td>${esc(record.leaveCount)} 人</td></tr>
</table>
<p><b>请假明细</b></p>
<table><tr><th style="width:30%">学生</th><th>请假原因</th></tr>${leaveRows}</table>
<p style="color:#888;font-size:10pt">提交时间：${esc(record.createdAt)}｜审核状态：待审核</p>
</body></html>`;
}

async function sendAttendanceMail(env: Env, teacher: any, record: any): Promise<string> {
  const toEmail = str(teacher.email);
  if (!toEmail) {
    await logMail(env, teacher, '', record, '无邮箱', '教师未绑定邮箱');
    return '无邮箱';
  }

  const apiKey = await getSetting(env, 'mail_api_key');
  const fromEmail = await getSetting(env, 'mail_from_email');
  if (!apiKey || !fromEmail) {
    await logMail(env, teacher, toEmail, record, '未配置', '管理员尚未配置邮件服务');
    return '未配置';
  }

  const html = buildWordHtml(teacher, record);
  const fileName = `打卡记录_${record.lessonLabel}_${record.createdAt.slice(0, 10)}.doc`;
  const contentB64 = bytesToB64(enc.encode(html));
  const fromName = await getSetting(env, 'mail_from_name', '教师工资统计系统');

  try {
    const resp = await fetch('https://api.brevo.com/v3/smtp/email', {
      method: 'POST',
      headers: {
        'content-type': 'application/json',
        'api-key': apiKey
      },
      body: JSON.stringify({
        sender: { name: fromName, email: fromEmail },
        to: [{ email: toEmail, name: teacher.name }],
        subject: `上课打卡记录 ${record.className} ${record.lessonLabel}`,
        htmlContent: html,
        attachment: [{ content: contentB64, name: fileName }]
      })
    });

    if (!resp.ok) {
      const text = await resp.text();
      await logMail(env, teacher, toEmail, record, '失败', text.slice(0, 300));
      return '发送失败';
    }
    await logMail(env, teacher, toEmail, record, '已发送', '');
    return '已发送';
  } catch (e: any) {
    await logMail(env, teacher, toEmail, record, '失败', String(e && e.message ? e.message : e).slice(0, 300));
    return '发送失败';
  }
}

async function logMail(env: Env, teacher: any, toEmail: string, record: any, status: string, error: string) {
  try {
    await env.DB.prepare(
      `INSERT INTO email_log (teacher_id, teacher_name, to_email, subject, content, status, error, created_at)
       VALUES (?, ?, ?, ?, ?, ?, ?, ?)`
    )
      .bind(
        teacher.id,
        teacher.name,
        toEmail,
        `上课打卡记录 ${record.className} ${record.lessonLabel}`,
        buildWordHtml(teacher, record),
        status,
        error,
        nowStr()
      )
      .run();
  } catch (e) {
    console.error('logMail failed', e);
  }
}

// ---------------- 健康检查 ----------------

async function health(env: Env): Promise<Response> {
  let db = 'ok';
  try {
    await env.DB.prepare('SELECT 1 AS ok').first();
  } catch {
    db = 'error';
  }
  return ok({ status: 'ok', db, time: nowStr(), service: 'school-salary-workers', version: 'v2' });
}

// ---------------- 路由 ----------------

async function handleApi(request: Request, url: URL, env: Env, ctx: any): Promise<Response> {
  const path = url.pathname.replace(/\/+$/, '') || '/';
  const method = request.method.toUpperCase();

  if (method === 'GET' && path === '/api/health') return health(env);

  if (method === 'POST' && path === '/api/auth/login') return login(request, env);
  if (method === 'POST' && path === '/api/auth/change-password') return changePassword(request, env);
  if (method === 'GET' && path === '/api/auth/profile') return profile(request, env);
  if (method === 'POST' && path === '/api/auth/profile') return updateProfile(request, env);

  if (method === 'POST' && path === '/api/admin/register') return createAdmin(request, env);
  if (method === 'GET' && path === '/api/admin/list') return listAdmins(request, env);
  if (method === 'POST' && path === '/api/admin/update') return updateAdmin(request, env);
  if (method === 'POST' && path === '/api/admin/delete') return deleteAdmin(request, env);

  if (method === 'POST' && path === '/api/teacher/register') return registerTeacher(request, env);
  if (method === 'GET' && path === '/api/teacher/list') return listTeachers(url, request, env);
  if (method === 'POST' && path === '/api/teacher/update') return updateTeacher(request, env);
  if (method === 'POST' && path === '/api/teacher/reset-password') return resetTeacherPassword(request, env);
  if (method === 'POST' && path === '/api/teacher/delete') return deleteTeacher(request, env);

  if (method === 'GET' && path === '/api/class/list') return listClasses(url, request, env);
  if (method === 'POST' && path === '/api/class/create') return createClass(request, env);
  if (method === 'POST' && path === '/api/class/delete') return deleteClass(request, env);
  if (method === 'POST' && path === '/api/class/rename') return renameClass(request, env);
  if (method === 'GET' && path === '/api/class/detail') return classDetail(url, request, env);
  if (method === 'POST' && path === '/api/class/students/save') return saveClassStudents(request, env);
  if (method === 'GET' && path === '/api/constants/classes') return jsonResponse({ code: 200, msg: 'success', data: {
    grades: Object.keys(GRADE_LABELS).map(c => ({ code: c, name: GRADE_LABELS[c] })),
    subjects: SUBJECT_OPTIONS,
    classTypes: CLASS_TYPE_OPTIONS
  }});

  if (method === 'GET' && path === '/api/classroom/list') return classroomList(request, env);
  if (method === 'POST' && path === '/api/classroom/save') return classroomSave(request, env);
  if (method === 'POST' && path === '/api/classroom/delete') return classroomDelete(request, env);

  if (method === 'GET' && path === '/api/schedule/list') return listSchedule(url, request, env);
  if (method === 'POST' && path === '/api/schedule/save') return saveSchedule(request, env);
  if (method === 'POST' && path === '/api/schedule/batch') return batchSchedule(request, env);
  if (method === 'POST' && path === '/api/schedule/delete') return deleteSchedule(request, env);
  if (method === 'POST' && path === '/api/schedule/renumber') return renumberSchedule(request, env);
  if (method === 'POST' && path === '/api/schedule/my/delete') return teacherDeleteSchedule(request, env);
  if (method === 'GET' && path === '/api/schedule/my') return mySchedule(url, request, env);
  if (method === 'POST' && path === '/api/schedule/issue') return setScheduleIssue(request, env);

  if (method === 'POST' && path === '/api/schedule/request') return scheduleRequestCreate(request, env);
  if (method === 'GET' && path === '/api/schedule/request/my') return scheduleRequestMy(request, env);
  if (method === 'GET' && path === '/api/schedule/request/list') return scheduleRequestList(url, request, env);
  if (method === 'POST' && path === '/api/schedule/request/audit') return scheduleRequestAudit(request, env);

  if (method === 'POST' && path === '/api/student/request') return studentRequestCreate(request, env);
  if (method === 'GET' && path === '/api/student/request/my') return studentRequestMy(request, env);
  if (method === 'GET' && path === '/api/student/request/list') return studentRequestList(url, request, env);
  if (method === 'POST' && path === '/api/student/request/audit') return studentRequestAudit(request, env);
  if (method === 'GET' && path === '/api/request/pending/count') return pendingCounts(request, env);

  if (method === 'POST' && path === '/api/attendance/submit') return submitAttendance(request, env, ctx);
  if (method === 'GET' && path === '/api/attendance/my') return attendanceMy(request, env);
  if (method === 'GET' && path === '/api/attendance/list') return attendanceList(url, request, env);
  if (method === 'POST' && path === '/api/attendance/delete') return deleteAttendance(request, env);

  const auditMatch = path.match(/^\/api\/attendance\/audit\/(\d+)$/);
  if (method === 'POST' && auditMatch) return attendanceAudit(Number(auditMatch[1]), request, env);

  if (method === 'GET' && path === '/api/salary/config') return salaryConfig(request, env);
  if (method === 'POST' && path === '/api/salary/config') return saveSalaryConfig(request, env);
  if (method === 'GET' && path === '/api/salary/teacher-rates') return teacherRateList(request, env);
  if (method === 'POST' && path === '/api/salary/teacher-rates') return saveTeacherRates(request, env);
  if (method === 'GET' && path === '/api/salary/report') return salaryReport(url, request, env);
  if (method === 'GET' && path === '/api/salary/export') return salaryExport(url, request, env);

  if (method === 'GET' && path === '/api/student/list') return studentList(url, request, env);
  if (method === 'GET' && path === '/api/student/detail') return studentDetail(url, request, env);
  if (method === 'GET' && path === '/api/student/schedule') return studentSchedule(url, request, env);
  if (method === 'POST' && path === '/api/student/save') return studentSave(request, env);
  if (method === 'POST' && path === '/api/student/delete') return studentDelete(request, env);
  if (method === 'POST' && path === '/api/student/course/save') return studentCourseSave(request, env);
  if (method === 'POST' && path === '/api/student/course/adjust') return studentCourseAdjust(request, env);
  if (method === 'POST' && path === '/api/student/course/delete') return studentCourseDelete(request, env);
  if (method === 'POST' && path === '/api/student/token') return studentRegenerateToken(request, env);
  if (method === 'GET' && path === '/api/public/student') return publicStudent(url, env);

  if (method === 'GET' && path === '/api/password-request/list') return passwordRequests(url, request, env);
  if (method === 'POST' && path === '/api/password-request/review') return reviewPasswordRequest(request, env);

  if ((method === 'GET' || method === 'POST') && path === '/api/mail/settings') return mailSettings(request, env);
  if (method === 'GET' && path === '/api/mail/list') return mailLogs(request, env);

  return fail('接口不存在: ' + method + ' ' + path, 404);
}

export default {
  async fetch(request: Request, env: Env, ctx: any): Promise<Response> {
    const url = new URL(request.url);

    if (request.method.toUpperCase() === 'OPTIONS') {
      return new Response(null, {
        status: 204,
        headers: {
          'access-control-allow-origin': '*',
          'access-control-allow-headers': 'Content-Type, Authorization',
          'access-control-allow-methods': 'GET, POST, PUT, DELETE, OPTIONS'
        }
      });
    }

    if (url.pathname === '/api' || url.pathname.startsWith('/api/')) {
      try {
        return await handleApi(request, url, env, ctx);
      } catch (e: any) {
        if (e instanceof ApiError) return fail(e.message, e.code);
        const msg = String(e && e.message ? e.message : '');
        // 并发写同一班次号时由唯一索引拦截，转成可读提示
        if (/UNIQUE constraint failed/i.test(msg)) {
          return fail('班次号冲突（可能有人在同时排课），请刷新后重试');
        }
        console.error('unhandled error', e && e.stack ? e.stack : e);
        return fail('系统内部错误: ' + msg, 500);
      }
    }

    return env.ASSETS.fetch(request);
  }
};
