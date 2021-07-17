namespace TextPieces {

    struct ScriptResult {
        string output;
        bool successful;
    }

    class Tool : Object {
        public static string CUSTOM_TOOLS_DIR;
        public static bool   in_flatpak;

        public string name { get; set; }
        public string description { get; set; }
        public string icon = "applications-utilities-symbolic";
        public string script;
        public bool   is_system;
        public string preferred_filename {
            owned get {
                var hash = Checksum.compute_for_string (
                    ChecksumType.SHA256,
                    name
                    + description
                    + Random
                        .int_range (1000000, 10000000)
                        .to_string (),
                    -1
                ).slice (0, 8);
                return name
                        .down ()
                        .replace (" ", "_")
                        .replace ("?", "x")
                        + "-"
                        + hash;
            }
        }

        static construct {
            CUSTOM_TOOLS_DIR = Path.build_filename (
                Environment.get_user_data_dir (), "textpieces", "scripts"
            );

            in_flatpak = File.new_for_path ("/.flatpak-info").query_exists (null);
        }

        public ScriptResult apply (string input) {
            var scriptdir = is_system
                ? Config.SCRIPTDIR
                : CUSTOM_TOOLS_DIR;

            string cmdline = (
                    (!is_system && in_flatpak)
                        ? "flatpak-spawn --host "
                        : ""
                ) + Path.build_filename (scriptdir, script);

            try {
                var process = new Subprocess.newv (
                    cmdline.split (" "),
                    SubprocessFlags.STDIN_PIPE |
                    SubprocessFlags.STDOUT_PIPE |
                    SubprocessFlags.STDERR_PIPE
                );

                string stdout;
                string stderr;
                process.communicate_utf8 (input, null, out stdout, out stderr);

                bool success = process.get_successful ();

                return {
                    success
                        ? stdout ?? ""
                        : stderr ?? _("Error while running script"),
                    success
                };
            } catch (Error e) {
                return {
                    e.message,
                    false
                };
            }
        }
    }

    Gtk.Widget build_list_row (Object item) {
        var tool = (Tool) item;

        return new Adw.ActionRow () {
            title = tool.name,
            subtitle = tool.description,
            icon_name = tool.icon,
            activatable = true
        };
    }
}
