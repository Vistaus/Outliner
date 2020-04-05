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
using GLib;

public class Outliner : Granite.Application {

  private static bool          show_version = false;
  private static string?       open_file    = null;
  private static bool          new_file     = false;
  private static bool          testing      = false;
  public  static string        version      = "1.0.3";
  public  static GLib.Settings settings;

  public Outliner () {
    Object( application_id: "com.github.phase1geo.outliner", flags: ApplicationFlags.FLAGS_NONE );
  }

  protected override void activate() {

    /* Initialize the settings */
    settings = new GLib.Settings( "com.github.phase1geo.outliner" );

    /* Add the application-specific icons */
    weak IconTheme default_theme = IconTheme.get_default();
    default_theme.add_resource_path( "/com/github/phase1geo/outliner" );

    /* Add the application CSS */
    var provider = new Gtk.CssProvider ();
    provider.load_from_resource( "/com/github/phase1geo/outliner/css/style.css" );
    Gtk.StyleContext.add_provider_for_screen( Gdk.Screen.get_default (), provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION );

    /* Create the main window */
    var appwin = new MainWindow( this, settings );

    /*
     If the user specified to open a specific filename from
     the command-line, attempt to open it.  Display an error
     message and exit immediately if there is an error opening
     the file.
    */
    if( open_file != null ) {
      if( !appwin.open_file( open_file ) ) {
        stdout.printf( "ERROR:  Unable to open file '%s'\n", open_file );
        Process.exit( 1 );
      }

    /*
     If the user specified that a new file should be created or the saved tab state
     was not loadable, create a new map.
    */
    } else if( new_file || !appwin.load_tab_state() ) {
      appwin.do_new_file();
    }

    /* Handle any changes to the position of the window */
    appwin.configure_event.connect(() => {
      int root_x, root_y;
      int size_w, size_h;
      appwin.get_position( out root_x, out root_y );
      appwin.get_size( out size_w, out size_h );
      settings.set_int( "window-x", root_x );
      settings.set_int( "window-y", root_y );
      settings.set_int( "window-w", size_w );
      settings.set_int( "window-h", size_h );
      return( false );
    });

    /* Run the main loop */
    Gtk.main();

  }

  /* Parse the command-line arguments */
  private void parse_arguments( ref unowned string[] args ) {

    var context = new OptionContext( "- Outliner Options" );
    var options = new OptionEntry[5];

    /* Create the command-line options */
    options[0] = {"version", 0, 0, OptionArg.NONE, ref show_version, "Display version number", null};
    options[1] = {"open", 'o', 0, OptionArg.FILENAME, ref open_file, "Open filename", "FILENAME"};
    options[2] = {"new", 'n', 0, OptionArg.NONE, ref new_file, "Starts Outliner with a new file", null};
    options[3] = {"run-tests", 0, 0, OptionArg.NONE, ref testing, "Run testing", null};
    options[4] = {null};

    /* Parse the arguments */
    try {
      context.set_help_enabled( true );
      context.add_main_entries( options, null );
      context.parse( ref args );
    } catch( OptionError e ) {
      stdout.printf( "ERROR: %s\n", e.message );
      stdout.printf( "Run '%s --help' to see valid options\n", args[0] );
      Process.exit( 1 );
    }

    /* If the version was specified, output it and then exit */
    if( show_version ) {
      stdout.printf( "%s\n", version );
      Process.exit( 0 );
    }

  }

  /* Main routine which gets everything started */
  public static int main( string[] args ) {

    var app = new Outliner();
    app.parse_arguments( ref args );

    if( testing ) {
      Gtk.init( ref args );
      var testing = new App.Tests.Testing( args );
      Idle.add(() => {
        testing.run();
        Gtk.main_quit();
        return( false );
      });
      Gtk.main();
      return( 0 );
    } else {
      return( app.run( args ) );
    }

  }

}

