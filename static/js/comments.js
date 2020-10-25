
var remark_config = {
  host: "https://b.sattellite.me/comments",
  site_id: 'sattelliteme',
  locale: window.navigator.language.split('-').pop(),
  theme: (function() {var m=window.matchMedia("(prefers-color-scheme: dark)"); return m.matches})() ? 'darK': 'light',
  show_email_subscription: false
};
