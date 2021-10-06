namespace TextPieces.Utils {
    public async void open_file (File file, Gtk.Window? window = null) {

        var is_successful = true;

        try {
            is_successful = yield AppInfo.launch_default_for_uri_async (
                file.get_uri (),
                null,
                null
            );
        } catch (Error _) {
            show_error_dialog (window);
        }

        if (!is_successful)
            show_error_dialog (window);

    }

    void show_error_dialog (Gtk.Window? window) {
        if (window != null) {
            var dialog = new Gtk.MessageDialog (
                window,
                Gtk.DialogFlags.MODAL | Gtk.DialogFlags.DESTROY_WITH_PARENT,
                Gtk.MessageType.ERROR,
                Gtk.ButtonsType.CLOSE,
                ""
            ) {
                text = _("Oops..."),
                secondary_text = _("Can't open script file")
            };
            dialog.response.connect (() => dialog.close ());
            dialog.present ();
        }
    }
}