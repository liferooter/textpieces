namespace TextPieces {

    struct ScriptResult {
        string output;
        bool successful;
    }

    class Tool : Object {
        public string name { get; set; }
        public string description { get; set; }
        public string icon;
        public string script;
        public bool   is_system;
        public bool   run_on_host { get; set; }

        public ScriptResult apply (string input) {
            var scriptdir = is_system
                ? Config.SCRIPTDIR
                : Path.build_filename (
                    Environment.get_user_data_dir (), "textpieces", "scripts"
                    );

            string cmdline = (
                    run_on_host
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
