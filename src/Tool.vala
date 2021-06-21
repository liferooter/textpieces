namespace TextPieces {

    class Tool : Object {
        public string name;
        public string description;
        public string icon;
    }

    Gtk.FilterListModel get_tools (TextPieces.Window window) {
        var list = new ListStore (typeof (Tool));

        list.append (
          new Tool () {
              name = "Linux",
              description = "The best OS ever",
              icon = "utilities-terminal-symbolic"
          }
        );
        list.append (
          new Tool () {
              name = "Window",
              description = "Must-die operation system",
              icon = "user-trash-symbolic"
          }
        );
        list.append (
          new Tool () {
              name = "YaKur",
              description = "Smoking",
              icon = "face-monkey-symbolic"
          }
        );
        list.append (
          new Tool () {
              name = "Telegram",
              description = "Cool messenger",
              icon = "mail-send-symbolic"
          }
        );

        return new Gtk.FilterListModel (
            list,
            new Gtk.CustomFilter (
                window.tool_filter_func
            )
        );
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
