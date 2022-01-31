// SPDX-FileCopyrightText: 2021 Christian Hergert <chergert@redhat.com>
// SPDX-FileCopyrightText: 2022 Gleb Smirnov <glebsmirnov0708@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

const string SHARED_CSS = """
@define-color card_fg_color @window_fg_color;
@define-color headerbar_fg_color @window_fg_color;
@define-color headerbar_border_color @window_fg_color;
@define-color popover_fg_color @window_fg_color;
@define-color dark_fill_bg_color @headerbar_bg_color;
@define-color view_bg_color @card_bg_color;
@define-color view_fg_color @window_fg_color;
""";

const string LIGHT_CSS_SUFFIX = """
@define-color popover_bg_color mix(@window_bg_color, white, .1);
@define-color card_bg_color alpha(white, .6);
""";

const string DARK_CSS_SUFFIX = """
@define-color popover_bg_color mix(@window_bg_color, white, 0.07);
@define-color card_bg_color @popover_bg_color;
@define-color view_bg_color darker(@window_bg_color);
""";

namespace Recoloring {

    enum ColorKind {
        FOREGROUND,
        BACKGROUND,
    }

    bool get_color (GtkSource.StyleScheme scheme,
                    string                style_name,
                    ColorKind             kind,
                    ref Gdk.RGBA          color) {
        var style = scheme.get_style (style_name);

        if (style == null)
            return false;

        var fg = style.foreground;
        var fg_set = style.foreground_set;
        var bg = style.background;
        var bg_set = style.background_set;

        if (kind == FOREGROUND && fg != null && fg_set)
            color.parse (fg);
        else if (kind == BACKGROUND && bg != null && bg_set)
            color.parse (bg);
        else
            return false;

        if (color.alpha >= 0.1)
            return true;
        else
            return false;
    }

    bool get_foreground (GtkSource.StyleScheme scheme,
                        string                 style_name,
                        ref Gdk.RGBA           color) {
        return get_color (scheme, style_name, FOREGROUND, ref color);
    }

    bool get_background (GtkSource.StyleScheme scheme,
                         string                style_name,
                         ref Gdk.RGBA          color) {
        return get_color (scheme, style_name, BACKGROUND, ref color);
    }

    bool get_metadata_color (GtkSource.StyleScheme scheme, string key, ref Gdk.RGBA color) {
        //  var str = scheme.get_metadata (key);
        string? str = null;

        if (str == null)
            return false;
        else
            return color.parse (str);
    }

    void define_color (StringBuilder str,
                       string        name,
                       Gdk.RGBA      color) {
        var opaque = color.copy ();
        opaque.alpha = 1.0f;

        var color_str = opaque.to_string ();
        str.append_printf ("@define-color %s %s;\n", name, color_str);
    }

    void define_color_mixed (StringBuilder str,
                             string        name,
                             Gdk.RGBA      a,
                             Gdk.RGBA      b,
                             double        level) {
        var a_str = a.to_string ();
        var b_str = b.to_string ();
        var level_string = level.to_string ();

        str.append_printf (
            "@define-color %s mix(%s, %s, %s);\n",
            name,
            a_str,
            b_str,
            level_string
        );
    }

    public bool is_scheme_dark (GtkSource.StyleScheme scheme) {
        string id = scheme.get_id ();
        string variant = null; // scheme.get_metadata ("variant");


        if (variant == "light")
            return false;
        else if (variant == "dark")
            return true;
        else if (id == "-dark")
            return true;

        var text_bg = Gdk.RGBA ();;
        if (get_background (scheme, "text", ref text_bg)) {
            /* http://alienryderflex.com/hsp.html */
            double r = text_bg.red * 255.0;
            double g = text_bg.green * 255.0;
            double b = text_bg.blue * 255.0;
            double hsp = Math.sqrt (0.299 * (r * r) +
                                    0.587 * (g * g) +
                                    0.114 * (b * b));

            return hsp <= 127.5;
        }

        return false;
    }

    public string generate_css (GtkSource.StyleScheme style_scheme) {
        Gdk.RGBA black = {0, 0, 0, 1};
        Gdk.RGBA white = {1, 1, 1, 1};

        /* Don't restyle Adwaita as we already have it */
        var id = style_scheme.get_name ();
        if (id.has_prefix ("Adwaita"))
            return "";

        var name = style_scheme.get_name ();
        var is_dark = is_scheme_dark (style_scheme);
        var alt = is_dark ? white : black;

        var str = new StringBuilder (SHARED_CSS);
        str.append_printf ("/* %s */\n", name);

        /* TODO: Improve error checking and fallbacks */

        var text_bg = is_dark
            ? black.copy ()
            : white.copy ();
        get_background (style_scheme, "text", ref text_bg);

        var text_fg = is_dark
            ? white.copy ()
            : black.copy ();
        get_foreground (style_scheme, "text", ref text_fg);

        var right_margin = text_bg.copy ();
        get_background (style_scheme, "right-margin", ref right_margin);
        right_margin.alpha = 1;

        if (is_dark)
            define_color_mixed (str, "window_bg_color", text_bg, alt, 0.025);
        else
            define_color_mixed (str, "window_bg_color", text_bg, white, 0.1);
        define_color_mixed (str, "window_fg_color", text_fg, alt, 0.1);

        if (is_dark)
            define_color_mixed (str, "headerbar_bg_color", text_bg, alt, 0.05);
        else
            define_color_mixed (str, "headerbar_bg_color", text_bg, alt, 0.025);
        define_color (str, "headerbar_fg_color", text_fg);

        define_color_mixed (str, "view_bg_color", text_bg, white, is_dark ? 0.1 : 0.3);
        define_color (str, "view_fg_color", text_fg);

        Gdk.RGBA color = {};

        if (get_metadata_color (style_scheme, "accent_bg_color", ref color) ||
                get_background (style_scheme, "selection", ref color))
            define_color (str, "accent_bg_color", color);

        if (get_metadata_color (style_scheme, "accent_fg_color", ref color) ||
                get_foreground (style_scheme, "selection", ref color))
            define_color (str, "accent_fg_color", color);

        if (get_metadata_color (style_scheme, "accent_color", ref color))
            define_color (str, "accent_color", color);
        else if (get_metadata_color (style_scheme, "accent_bg_color", ref color) ||
                    get_background (style_scheme, "selection", ref color)) {
            color.alpha = 1;
            define_color_mixed (str, "accent_color", color, alt, 0.1);
        }

        if (is_dark)
            str.append(DARK_CSS_SUFFIX);
        else
            str.append(LIGHT_CSS_SUFFIX);

        return str.str;
    }
}