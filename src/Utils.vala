namespace TextPieces.Xdp {
    public const string PORTAL_OBJECT_PATH = "/org/freedesktop/portal/desktop";
    public const string PORTAL_BUS_NAME = "org.freedesktop.portal.Desktop";

    [DBus (name = "org.freedesktop.portal.OpenURI")]
    public interface OpenURI : Object {
        public abstract async ObjectPath open_u_r_i (string parent_window,
                                               string uri,
                                               HashTable<string, Variant> options) throws DBusError, IOError;
        public abstract async ObjectPath open_file  (string parent_window,
                                               UnixInputStream file,
                                               HashTable<string, Variant> options) throws DBusError, IOError;
    }

    [DBus (name = "org.freedesktop.portal.Request")]
    public interface Request : Object {
        public abstract async void close () throws DBusError, IOError;
        public signal void response (uint response, HashTable<string, Variant> results);
    }
}

namespace TextPieces.Utils {
    public async void open_file (File file, Gtk.Window? window = null) {
        
        var is_successful = true;
        
        try {
            FileStream* filestream = FileStream.open (file.get_path (), "rw");

            if (filestream == null) {
                critical ("Can't open file %s", file.get_path ());
                show_error_dialog (window);
                return;
            }

            var parent_window = "";
            var fd = new UnixInputStream (filestream->fileno (), false);
            var options = new HashTable<string, Variant> (null, null);

            var token = Random.next_int ().to_string ();
            var sender =
                (yield Bus.get (BusType.SESSION))
                .get_unique_name ()
                .replace (":", "")
                .replace (".", "_");
            var request_path = @"$(Xdp.PORTAL_OBJECT_PATH)/request/$sender/$token";
            
            Xdp.Request request = yield Bus.get_proxy (
                BusType.SESSION,
                Xdp.PORTAL_BUS_NAME,
                request_path
            );

            request.response.connect ((code, results) => {
                if (code != 0)
                    is_successful = false;
            });

            options["handle_token"] = token;

            if (window != null) {
                var surface = ((!) window).get_surface ();
                if (surface is Gdk.X11.Surface) {
                    var x11_surface = ((Gdk.X11.Surface) surface);
                    parent_window = "x11:%d".printf (((int) x11_surface.get_xid ()));
                } else if (surface is Gdk.Wayland.Toplevel) {
                    var wayland_toplevel = (Gdk.Wayland.Toplevel) surface;
                    wayland_toplevel.export_handle ((toplevel, handle) => {
                        parent_window = @"wayland:$handle";
                    });
                    wayland_toplevel.unexport_handle ();
                }
            }

            Xdp.OpenURI openuri = yield Bus.get_proxy (
                BusType.SESSION,
                Xdp.PORTAL_BUS_NAME,
                Xdp.PORTAL_OBJECT_PATH
            );
            
            var real_request_path = yield openuri.open_file (parent_window, fd, options);
            assert (real_request_path == request_path);

            yield request.close ();

            free (filestream);

        } catch (DBusError e) {
            critical ("DBus error: %s", e.message);
            is_successful = false;
        } catch (IOError e) {
            critical ("I/O error: %s", e.message);
            is_successful = false;
        } finally {
            if (!is_successful)
                show_error_dialog (window);
        }
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