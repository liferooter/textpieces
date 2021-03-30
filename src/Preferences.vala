namespace Textpieces {
    [GtkTemplate (ui = "/com/github/liferooter/textpieces/ui/preferences.ui")]
    class Preferences : Hdy.PreferencesWindow {
        [GtkChild]
        private unowned Gtk.Switch prefer_dark;
        [GtkChild]
        private unowned Gtk.Switch show_line_numbers;
        [GtkChild]
        private unowned Gtk.Switch show_grid;
        [GtkChild]
        private unowned Gtk.Switch tab_to_spaces;

        public Preferences (Gtk.Window win) {
            Object ();
            this.set_transient_for (win);


            Textpieces.Application.settings.bind ("prefer-dark",
                                                  prefer_dark,
                                                  "active",
                                                  SettingsBindFlags.DEFAULT);
            Textpieces.Application.settings.bind ("show-line-numbers",
                                                  show_line_numbers,
                                                  "active",
                                                  SettingsBindFlags.DEFAULT);
            Textpieces.Application.settings.bind ("show-grid",
                                                  show_grid,
                                                  "active",
                                                  SettingsBindFlags.DEFAULT);
            Textpieces.Application.settings.bind ("tab-to-spaces",
                                                  tab_to_spaces,
                                                  "active",
                                                  SettingsBindFlags.DEFAULT);
        }
    }
}
