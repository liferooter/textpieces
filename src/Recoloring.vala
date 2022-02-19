// SPDX-FileCopyrightText: 2021 Christian Hergert <chergert@redhat.com>
// SPDX-FileCopyrightText: 2022 Gleb Smirnov <glebsmirnov0708@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

/*
 FIXME: there are some lines of code in this file
        which uses unstable API from gtksourceview-5.4.
        These lines are commented. Uncomment them after
        gtksourceview-5.4 release.
 */

using GtkSource;
using Gdk;

/**
 * CSS that should be loaded for any style scheme
 * except Adwaita or Adwaita-dark.
 */
const string SHARED_CSS = """
@define-color card_fg_color @window_fg_color;
@define-color headerbar_fg_color @window_fg_color;
@define-color headerbar_border_color @window_fg_color;
@define-color popover_fg_color @window_fg_color;
@define-color dark_fill_bg_color @headerbar_bg_color;
@define-color view_bg_color @card_bg_color;
@define-color view_fg_color @window_fg_color;
""";

/**
 * CSS that should be loaded for any light style
 * schemes except Adwaita.
 */
const string LIGHT_CSS_SUFFIX = """
@define-color popover_bg_color mix(@window_bg_color, white, .1);
@define-color card_bg_color alpha(white, .6);
""";

/**
 * CSS that should be loaded for any dark style
 * schemes except Adwaita-dark.
 */
const string DARK_CSS_SUFFIX = """
@define-color popover_bg_color mix(@window_bg_color, white, 0.07);
@define-color card_bg_color @popover_bg_color;
@define-color view_bg_color darker(@window_bg_color);
""";

/**
 * Implementation of application-wide style schemes.
 */
namespace Recoloring {
    /**
     * Color kind.
     *
     * Can be background or foreground.
     */
    enum ColorKind {
        FOREGROUND,
        BACKGROUND,
    }

    /**
     * Try to parse color string.
     *
     * Returns `null` if string is invalid.
     *
     * @param color color string
     *
     * @return color got from string, or `null` if string is invalid
     */
    RGBA? parse_color (string color) {
        var rgba = RGBA ();

        if (rgba.parse (color))
            return rgba;
        else
            return null;
    }

    /**
     * Get color from style scheme.
     *
     * @param scheme style scheme
     * @param style_name style name that color is belong to
     * @param kind color kind
     *
     * @return color
     */
    RGBA? get_color (StyleScheme scheme, string style_name, ColorKind kind) {
        var style = scheme.get_style (style_name);

        if (style == null)
            return null;

        var fg = style.foreground;
        var fg_set = style.foreground_set;
        var bg = style.background;
        var bg_set = style.background_set;

        var color = RGBA ();

        if (kind == FOREGROUND && fg != null && fg_set)
            color.parse (fg);
        else if (kind == BACKGROUND && bg != null && bg_set)
            color.parse (bg);
        else
            return null;

        if (color.alpha >= 0.1)
            return color;
        else
            return null;
    }

    /**
     * Get color from style scheme metadata.
     *
     * @param scheme style scheme
     * @param key color key
     *
     * @return color, or `null` if not defined
     */
    RGBA? get_metadata_color (StyleScheme scheme, string key) {
        //  var str = scheme.get_metadata (key);
        string? str = null;

        if (str == null)
            return null;
        else
            return parse_color (str);
    }

    /**
     * Define color in CSS string builder.
     *
     * @param str CSS string builder
     * @param name color name
     * @param color color to define
     */
    void define_color (StringBuilder str, string name, RGBA? color) {
        if (color == null)
            return;

        var opaque = color.copy ();
        opaque.alpha = 1.0f;

        var color_str = opaque.to_string ();
        str.append_printf ("@define-color %s %s;\n", name, color_str);
    }

    /**
     * Define mixed color in CSS string builder.
     *
     * @param str CSS string builder
     * @param name color name
     * @param a first color
     * @param b second color
     * @param level mix level
     */
    void define_color_mixed (StringBuilder str,
                             string name,
                             RGBA a,
                             RGBA b,
                             double level) {
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

    /**
     * Get whether style scheme is dark.
     *
     * @param scheme style scheme
     *
     * @return whether the style scheme is dark
     */
     public bool is_scheme_dark (StyleScheme scheme) {
        string id = scheme.get_id ();
        string variant = null; // scheme.get_metadata ("variant");


        if (variant == "light")
            return false;
        else if (variant == "dark")
            return true;
        else if (id.has_suffix ("-dark"))
            return true;

        var text_bg = get_color (scheme, "text", BACKGROUND);
        if (text_bg != null) {
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

    /**
     * Generate CSS for style scheme.
     *
     * This function is used to apply `gtksourceview`'s
     * style schemes to whole application.
     *
     * @param style_scheme style scheme
     *
     * @return CSS string to apply on application
     */
    public string generate_css (StyleScheme style_scheme) {
        RGBA black = {0, 0, 0, 1};
        RGBA white = {1, 1, 1, 1};

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

        var text_bg = get_color (style_scheme, "text", BACKGROUND)
            ?? (is_dark
                ? black
                : white);

        var text_fg = get_color (style_scheme, "text", FOREGROUND)
            ?? (is_dark
                ? white
                : black);

        var right_margin = get_color (style_scheme, "right-margin", BACKGROUND)
            ?? text_bg;
        right_margin.alpha = 1;

        if (is_dark) {
            define_color_mixed (str, "window_bg_color", text_bg, alt, 0.025);
            define_color_mixed (str, "headerbar_bg_color", text_bg, alt, 0.05);
        } else {
            define_color_mixed (str, "window_bg_color", text_bg, white, 0.1);
            define_color_mixed (str, "headerbar_bg_color", text_bg, alt, 0.025);
        }

        define_color_mixed (str, "window_fg_color", text_fg, alt, 0.1);
        define_color (str, "headerbar_fg_color", text_fg);

        define_color_mixed (str, "view_bg_color", text_bg, white, is_dark ? 0.1 : 0.3);
        define_color (str, "view_fg_color", text_fg);


        define_color (
            str,
            "accent_bg_color",
            get_metadata_color (style_scheme, "accent_bg_color")
                ?? get_color (style_scheme, "selection", BACKGROUND)
        );

        define_color (
            str,
            "accent_fg_color",
            get_metadata_color (style_scheme, "accent_fg_color")
                ?? get_color (style_scheme, "selection", FOREGROUND)
        );

        var accent_color = get_metadata_color (style_scheme, "accent_color");
        if (accent_color != null) {
            define_color (str, "accent_color", accent_color);
        } else {
            accent_color = get_metadata_color (style_scheme, "accent_bg_color")
                ?? get_color (style_scheme, "selection", BACKGROUND);

            if (accent_color != null) {
                accent_color.alpha = 1;
                define_color_mixed (str, "accent_color", accent_color, alt, 0.1);
            }
        }

        if (is_dark)
            str.append(DARK_CSS_SUFFIX);
        else
            str.append(LIGHT_CSS_SUFFIX);

        return str.str;
    }
}
