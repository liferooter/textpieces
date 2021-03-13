namespace Textpieces {
    [GtkTemplate (ui = "/com/github/liferooter/textpieces/ui/about.ui")]
    class AboutDialog : Gtk.AboutDialog {
        public AboutDialog (Gtk.Window win) {
            Object ();
            this.set_transient_for (win);
        }
    }
}
