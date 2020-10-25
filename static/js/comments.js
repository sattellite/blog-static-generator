;
var remark_config = {
  host: "https://b.sattellite.me/comments",
  site_id: 'sattelliteme',
  locale: window.navigator.language.split('-').pop(),
  theme: (function() {var m=window.matchMedia("(prefers-color-scheme: dark)"); return m.matches})() ? 'dark' : 'light',
  show_email_subscription: false
};

window.matchMedia('(prefers-color-scheme: dark)')
  .addListener(e => window.REMARK42.changeTheme(e.matches ? 'dark' : 'light'));
