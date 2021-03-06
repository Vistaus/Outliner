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

public class UndoNodeReplace : UndoItem {

  private Node _orig_node;
  private Node _new_node;

  public UndoNodeReplace( Node orig_node, Node new_node ) {
    base( _( "replace node") );
    _orig_node = orig_node;
    _new_node  = new_node;
  }

  public override void undo( OutlineTable ot ) {
    ot.replace_node( _new_node, _orig_node );
    ot.queue_draw();
    ot.changed();
  }

  public override void redo( OutlineTable ot ) {
    ot.replace_node( _orig_node, _new_node );
    ot.queue_draw();
    ot.changed();
  }

}

