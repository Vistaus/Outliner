/*
* Copyright (c) 2020 (https://github.com/phase1geo/Outliner)
*
* This program is free software; you can redistribute it and/or
* modify it under the terms of the GNU General Public
* License as published by the Free Software Foundation; either
* version 2 of the License, or (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
* General Public License for more details.
*
* You should have received a copy of the GNU General Public
* License along with this program; if not, write to the
* Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
* Boston, MA 02110-1301 USA
*
* Authored by: Trevor Williams <phase1geo@gmail.com>
*/

using Gtk;
using Gdk;

public class FormatBar : Gtk.Popover {

  private OutlineTable _table;
  private Button       _copy;
  private Button       _cut;
  private ToggleButton _bold;
  private ToggleButton _italics;
  private ToggleButton _underline;
  private ToggleButton _strike;
  private ToggleButton _code;
  private ToggleButton _super;
  private ToggleButton _sub;
  private MenuButton   _header;
  private ToggleButton _hilite;
  private ColorButton  _hilite_chooser;
  private ToggleButton _color;
  private ColorButton  _color_chooser;
  private ToggleButton _link;
  private bool         _ignore_active = false;
  private LinkEditor   _link_editor;

  /* Construct the formatting bar */
  public FormatBar( OutlineTable table ) {

    _table = table;

    relative_to = table;
    modal       = false;

    _link_editor = new LinkEditor( table );

    var box = new Box( Orientation.HORIZONTAL, 0 );
    box.border_width = 5;

    _copy = new Button.from_icon_name( "edit-copy-symbolic", IconSize.SMALL_TOOLBAR );
    _copy.relief = ReliefStyle.NONE;
    _copy.set_tooltip_markup( Utils.tooltip_with_accel( _( "Copy" ), "<Control>c" ) );
    _copy.clicked.connect( handle_copy );

    _cut = new Button.from_icon_name( "edit-cut-symbolic", IconSize.SMALL_TOOLBAR );
    _cut.relief = ReliefStyle.NONE;
    _cut.set_tooltip_markup( Utils.tooltip_with_accel( _( "Cut" ), "<Control>x" ) );
    _cut.clicked.connect( handle_cut );

    _bold = new ToggleButton();
    _bold.image  = new Image.from_icon_name( "format-text-bold-symbolic", IconSize.SMALL_TOOLBAR );
    _bold.relief = ReliefStyle.NONE;
    _bold.set_tooltip_markup( Utils.tooltip_with_accel( _( "Bold" ), "<Control>b" ) );
    _bold.toggled.connect( handle_bold );

    _italics = new ToggleButton();
    _italics.image  = new Image.from_icon_name( "format-text-italic-symbolic", IconSize.SMALL_TOOLBAR );
    _italics.relief = ReliefStyle.NONE;
    _italics.set_tooltip_markup( Utils.tooltip_with_accel( _( "Italic" ), "<Control>i" ) );
    _italics.toggled.connect( handle_italics );

    _underline = new ToggleButton();
    _underline.image  = new Image.from_icon_name( "format-text-underline-symbolic", IconSize.SMALL_TOOLBAR );
    _underline.relief = ReliefStyle.NONE;
    _underline.set_tooltip_text( _( "Underline" ) );
    _underline.toggled.connect( handle_underline );

    _strike = new ToggleButton();
    _strike.image  = new Image.from_icon_name( "format-text-strikethrough-symbolic", IconSize.SMALL_TOOLBAR );
    _strike.relief = ReliefStyle.NONE;
    _strike.set_tooltip_text( _( "Strikethrough" ) );
    _strike.toggled.connect( handle_strikethru );

    _code = new ToggleButton();
    _code.image = new Image.from_resource( "/com/github/phase1geo/outliner/images/code-symbolic" );
    _code.relief = ReliefStyle.NONE;
    _code.set_tooltip_text( _( "Code Block" ) );
    _code.toggled.connect( handle_code );

    _super = new ToggleButton();
    _super.image = new Image.from_resource( "/com/github/phase1geo/outliner/images/superscript-symbolic" );
    _super.relief = ReliefStyle.NONE;
    _super.set_tooltip_text( _( "Superscript" ) );
    _super.toggled.connect( handle_superscript );

    _sub = new ToggleButton();
    _sub.image = new Image.from_resource( "/com/github/phase1geo/outliner/images/subscript-symbolic" );
    _sub.relief = ReliefStyle.NONE;
    _sub.set_tooltip_text( _( "Subscript" ) );
    _sub.toggled.connect( handle_subscript );

    _header = new MenuButton();
    _header.image = new Image.from_resource( "/com/github/phase1geo/outliner/images/header-symbolic" );
    _header.relief = ReliefStyle.NONE;
    _header.popup = new Gtk.Menu();
    unowned SList<RadioMenuItem>? group = null;
    for( int i=0; i<7; i++ ) {
      var mi    = new Gtk.RadioMenuItem.with_label( group, (i == 0) ? _( "None" ) : "<H%d>".printf( i ) );
      var level = i;
      mi.activate.connect(() => {
        handle_header( level );
      });
      _header.popup.add( mi );
      if( group == null ) {
        group = mi.get_group();
      }
    }
    _header.popup.show_all();

    _hilite        = new ToggleButton();
    _hilite.label  = " ";
    _hilite.relief = ReliefStyle.NONE;
    _hilite.set_tooltip_text( _( "Apply Highlight Color" ) );
    _hilite.toggled.connect( handle_highlight );
    _hilite.get_style_context().add_class( "hilite" );

    _hilite_chooser = new ColorButton.with_rgba( get_hilite_color() );
    _hilite_chooser.label  = "\u23f7";
    _hilite_chooser.relief = ReliefStyle.NONE;
    _hilite_chooser.set_tooltip_text( _( "Change Highlight Color" ) );
    _hilite_chooser.color_set.connect( handle_highlight_chooser );
    _hilite_chooser.get_style_context().add_class( "color_chooser" );

    _color        = new ToggleButton();
    _color.label  = " ";
    _color.relief = ReliefStyle.NONE;
    _color.set_tooltip_text( "Apply Font Color" );
    _color.toggled.connect( handle_color );
    _color.get_style_context().add_class( "fcolor" );

    _color_chooser = new ColorButton.with_rgba( get_font_color() );
    _color_chooser.label  = "\u23f7";
    _color_chooser.relief = ReliefStyle.NONE;
    _color_chooser.set_tooltip_text( _( "Change Font Color" ) );
    _color_chooser.color_set.connect( handle_color_chooser );
    _color_chooser.get_style_context().add_class( "color_chooser" );

    _link = new ToggleButton();
    _link.image = new Image.from_icon_name( "insert-link-symbolic", IconSize.SMALL_TOOLBAR );
    _link.relief = ReliefStyle.NONE;
    _link.set_tooltip_text( _( "Link" ) );
    _link.toggled.connect( handle_link );

    var spacer = "    ";

    box.pack_start( _copy,               false, false, 0 );
    box.pack_start( _cut,                false, false, 0 );
    box.pack_start( new Label( spacer ), false, false, 0 );
    box.pack_start( _bold,               false, false, 0 );
    box.pack_start( _italics,            false, false, 0 );
    box.pack_start( _underline,          false, false, 0 );
    box.pack_start( _strike,             false, false, 0 );
    box.pack_start( _code,               false, false, 0 );
    box.pack_start( _super,              false, false, 0 );
    box.pack_start( _sub,                false, false, 0 );
    box.pack_start( _header,             false, false, 0 );
    box.pack_start( new Label( spacer ), false, false, 0 );
    box.pack_start( _hilite,             false, false, 0 );
    box.pack_start( _hilite_chooser,     false, false, 0 );
    box.pack_start( new Label( spacer ), false, false, 0 );
    box.pack_start( _color,              false, false, 0 );
    box.pack_start( _color_chooser,      false, false, 0 );
    box.pack_start( new Label( spacer ), false, false, 0 );
    box.pack_start( _link,               false, false, 0 );

    add( box );

    show_all();

    initialize();

  }

  private RGBA get_hilite_color() {
    if( _table.hilite_color == null ) {
      return( _table.get_theme().hilite );
    } else {
      RGBA color = {1.0, 1.0, 1.0, 1.0};
      color.parse( _table.hilite_color );
      return( color );
    }
  }

  private RGBA get_font_color() {
    if( _table.font_color == null ) {
      return( _table.get_theme().foreground );
    } else {
      RGBA color = {1.0, 1.0, 1.0, 1.0};
      color.parse( _table.font_color );
      return( color );
    }
  }

  private void close() {
#if GTK322
    popdown();
#else
    hide();
#endif
  }

  private void format_text( FormatTag tag, string? extra=null ) {
    if( _table.selected.mode == NodeMode.EDITABLE ) {
      _table.selected.name.add_tag( tag, extra, _table.undo_text );
    } else {
      _table.selected.note.add_tag( tag, extra, _table.undo_text );
    }
    _table.queue_draw();
    _table.changed();
    _table.grab_focus();
  }

  private void unformat_text( FormatTag tag ) {
    if( _table.selected.mode == NodeMode.EDITABLE ) {
      _table.selected.name.remove_tag( tag, _table.undo_text );
    } else {
      _table.selected.note.remove_tag( tag, _table.undo_text );
    }
    _table.queue_draw();
    _table.changed();
    _table.grab_focus();
  }

  /* Copies the selected text to the clipboard */
  private void handle_copy() {
    _table.do_copy();
    close();
  }

  /* Cuts the selected text to the clipboard */
  private void handle_cut() {
    _table.do_cut();
    close();
  }

  /* Toggles the bold status of the currently selected text */
  private void handle_bold() {
    if( !_ignore_active ) {
      if( _bold.active ) {
        format_text( FormatTag.BOLD );
      } else {
        unformat_text( FormatTag.BOLD );
      }
    }
  }

  /* Toggles the italics status of the currently selected text */
  private void handle_italics() {
    if( !_ignore_active ) {
      if( _italics.active ) {
        format_text( FormatTag.ITALICS );
      } else {
        unformat_text( FormatTag.ITALICS );
      }
    }
  }

  /* Toggles the underline status of the currently selected text */
  private void handle_underline() {
    if( !_ignore_active ) {
      if( _underline.active ) {
        format_text( FormatTag.UNDERLINE );
      } else {
        unformat_text( FormatTag.UNDERLINE );
      }
    }
  }

  /* Toggles the strikethru status of the currently selected text */
  private void handle_strikethru() {
    if( !_ignore_active ) {
      if( _strike.active ) {
        format_text( FormatTag.STRIKETHRU );
      } else {
        unformat_text( FormatTag.STRIKETHRU );
      }
    }
  }

  /* Toggles the code status of the currently selected text */
  private void handle_code() {
    if( !_ignore_active ) {
      if( _code.active ) {
        format_text( FormatTag.CODE );
      } else {
        unformat_text( FormatTag.CODE );
      }
    }
  }

  /* Toggles the superscript status of the currently selected text */
  private void handle_superscript() {
    if( !_ignore_active ) {
      if( _super.active ) {
        format_text( FormatTag.SUPER );
      } else {
        unformat_text( FormatTag.SUPER );
      }
    }
  }

  /* Toggles the superscript status of the currently selected text */
  private void handle_subscript() {
    if( !_ignore_active ) {
      if( _sub.active ) {
        format_text( FormatTag.SUB );
      } else {
        unformat_text( FormatTag.SUB );
      }
    }
  }

  /* Toggles the header status of the currently selected text */
  private void handle_header( int level ) {
    if( !_ignore_active ) {
      if( level > 0 ) {
        format_text( FormatTag.HEADER, level.to_string() );
      } else {
        unformat_text( FormatTag.HEADER );
      }
    }
  }

  /* Toggles the highlight status of the currently selected text */
  private void handle_highlight() {
    if( !_ignore_active ) {
      if( _hilite.active ) {
        format_text( FormatTag.HILITE, _table.hilite_color );
      } else {
        unformat_text( FormatTag.HILITE );
      }
    }
  }

  /* Picks a new color to set the selected text highlighter to */
  private void handle_highlight_chooser() {
    _table.hilite_color = Utils.color_from_rgba( _hilite_chooser.rgba );
    format_text( FormatTag.HILITE, _table.hilite_color );
  }

  /* Toggles the foreground color of the currently selected text */
  private void handle_color() {
    if( !_ignore_active ) {
      if( _color.active ) {
        format_text( FormatTag.COLOR, _table.font_color );
      } else {
        unformat_text( FormatTag.COLOR );
      }
    }
  }

  /* Picks a new color to set the selected foreground color to */
  private void handle_color_chooser() {
    _table.font_color = Utils.color_from_rgba( _color_chooser.rgba );
    format_text( FormatTag.COLOR, _table.font_color );
  }

  /* Creates a link out of the currently selected text */
  private void handle_link() {
    if( !_ignore_active ) {
      if( _link.active ) {
        if( _table.selected.mode == NodeMode.EDITABLE ) {
          _link_editor.add_url( _table.selected.name );
        } else {
          _link_editor.add_url( _table.selected.note );
        }
        _table.queue_draw();
        _table.changed();
      } else {
        unformat_text( FormatTag.URL );
      }
    }
  }

  /* Sets the active status of the given toggle button */
  private void set_toggle_button( CanvasText text, FormatTag tag, ToggleButton btn ) {
    btn.set_active( text.text.is_tag_applied_in_range( tag, text.selstart, text.selend ) );
  }

  private void activate_header( int index ) {
    var buttons = _header.popup.get_children();
    var button  = (CheckMenuItem)buttons.nth_data( index );
    button.set_active( true );
  }

  /* Sets the active status of the correct header radio menu item */
  private void set_header( CanvasText text ) {
    var header  = text.text.get_first_extra_in_range( FormatTag.HEADER, text.selstart, text.selend );
    if( header == null ) {
      activate_header( 0 );
    } else {
      switch( header ) {
        case "1" :  activate_header( 1 );  break;
        case "2" :  activate_header( 2 );  break;
        case "3" :  activate_header( 3 );  break;
        case "4" :  activate_header( 4 );  break;
        case "5" :  activate_header( 5 );  break;
        case "6" :  activate_header( 6 );  break;
      }
    }
  }

  /*
   Updates the state of the format bar based on the state of the current
   text.
  */
  private void update_from_text( CanvasText? text ) {
    _ignore_active = true;
    set_toggle_button( text, FormatTag.BOLD,       _bold );
    set_toggle_button( text, FormatTag.ITALICS,    _italics );
    set_toggle_button( text, FormatTag.UNDERLINE,  _underline );
    set_toggle_button( text, FormatTag.STRIKETHRU, _strike );
    set_toggle_button( text, FormatTag.CODE,       _code );
    set_toggle_button( text, FormatTag.SUPER,      _super );
    set_toggle_button( text, FormatTag.SUB,        _sub );
    set_toggle_button( text, FormatTag.HILITE,     _hilite );
    set_toggle_button( text, FormatTag.COLOR,      _color );
    set_toggle_button( text, FormatTag.URL,        _link );
    set_header( text );
    _ignore_active = false;
  }

  /*
   Updates the state of the format bar based on which tags are applied at the
   current cursor position.
  */
  public void initialize() {
    if( _table.selected.mode == NodeMode.EDITABLE ) {
      update_from_text( _table.selected.name );
    } else {
      update_from_text( _table.selected.note );
    }
  }

}
