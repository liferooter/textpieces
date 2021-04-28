namespace Textpieces {
    [GtkTemplate (ui = "/com/github/liferooter/textpieces/ui/about.ui")]
    class AboutDialog : Gtk.AboutDialog {
        public AboutDialog (Gtk.Window win) {
            Object (
                version: Config.VERSION,
                logo_icon_name: Config.APP_ID
            );
            this.set_transient_for (win);
        }
    }
}
