namespace Textpieces {
    [GtkTemplate (ui = "/com/github/liferooter/textpieces/ui/argument.ui")]
    class Argument : Gtk.Box {
        [GtkChild]
        private unowned Gtk.Label arg_label;
        [GtkChild]
        public unowned Gtk.Entry arg_entry;

        public Argument (string name) {
            Object ();
            arg_label.set_label (name);
        }

        construct {
            this.show_all ();
        }
    }
}