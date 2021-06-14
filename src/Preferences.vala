namespace TextPieces {
    [GtkTemplate (ui = "/com/github/liferooter/textpieces/ui/Preferences.ui")]
    class Preferences : Adw.PreferencesWindow {

        private const string[] PREF_ACTIONS = {
            "dark-theme"
        };

        construct {
            var action_group = new SimpleActionGroup ();
            foreach (var pref in PREF_ACTIONS) {
                action_group.add_action (TextPieces.Application.settings.create_action (pref));
            }
            insert_action_group ("prefs", action_group);
        }
    }
}
