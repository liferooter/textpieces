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
              icon = "mail-send-symbolic"
          }
        );
        list.append (
          new Tool () {
              name = "Window",
              description = "Must-die operation system",
              icon = "mail-send-symbolic"
          }
        );
        list.append (
          new Tool () {
              name = "YaKur",
              description = "The best OS ever",
              icon = "mail-send-symbolic"
          }
        );
        list.append (
          new Tool () {
              name = "DDD",
              description = "The best OS ever",
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
