namespace Textpieces {
    [GtkTemplate (ui = "/com/github/liferooter/textpieces/ui/shortcuts.ui")]
    public class ShortcutsWindow : Gtk.ShortcutsWindow {
        public ShortcutsWindow (MainWindow window) {
            Object ();
            this.set_transient_for (window);
        }
    }
}
