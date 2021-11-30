namespace TextPieces.Utils {
    public async void open_file (File file, Gtk.Window? window = null) {

        var is_successful = true;

        try {
            is_successful = yield AppInfo.launch_default_for_uri_async (
                file.get_uri (),
                null,
                null
            );
        } catch (Error e) {
            show_error_dialog (e.message, window);
        }

        if (!is_successful)
            show_error_dialog ("unknown error", window);
    }

    void show_error_dialog (string msg, Gtk.Window? window) {
        critical (@"Can't open file: $msg");
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