export default defineAppConfig({
  pages: [
    'pages/index/index',
    'pages/schedule/index',
    'pages/salary/index',
    'pages/salary/detail',
    'pages/attendance/end',
    'pages/me/index'
  ],
  window: {
    backgroundTextStyle: 'light',
    navigationBarBackgroundColor: '#ffffff',
    navigationBarTitleText: '教师端',
    navigationBarTextStyle: 'black'
  },
  tabBar: {
    color: '#999999',
    selectedColor: '#1677ff',
    backgroundColor: '#ffffff',
    borderStyle: 'black',
    list: [
      {
        pagePath: 'pages/index/index',
        text: '首页'
      },
      {
        pagePath: 'pages/schedule/index',
        text: '课表'
      },
      {
        pagePath: 'pages/salary/index',
        text: '工资'
      },
      {
        pagePath: 'pages/me/index',
        text: '我的'
      }
    ]
  }
})
