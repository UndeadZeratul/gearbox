/* Copyright Alexander Kromm (mmaulwurff@gmail.com) 2020-2021
 *
 * This file is part of Gearbox.
 *
 * Gearbox is free software: you can redistribute it and/or modify it under the
 * terms of the GNU General Public License as published by the Free Software
 * Foundation, either version 3 of the License, or (at your option) any later
 * version.
 *
 * Gearbox is distributed in the hope that it will be useful, but WITHOUT ANY
 * WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
 * A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along with
 * Gearbox.  If not, see <https://www.gnu.org/licenses/>.
 */

/**
 * This class stores top-level Gearbox state. It can be either Weapons,
 * Inventory, or None.
 */
class gb_Activity
{

  static
  gb_Activity from()
  {
    let result = new("gb_Activity");
    result.mActivity = gb_Activity.None;
    return result;
  }

  bool isNone()      const { return mActivity == gb_Activity.None;      }
  bool isWeapons()   const { return mActivity == gb_Activity.Weapons;   }
  bool isInventory() const { return mActivity == gb_Activity.Inventory; }

  void toggleWeaponMenu()
  {
    switch (mActivity)
    {
    case gb_Activity.Inventory:
    case gb_Activity.None:    mActivity = gb_Activity.Weapons; break;
    case gb_Activity.Weapons: mActivity = gb_Activity.None;    break;
    }
  }

// private: ////////////////////////////////////////////////////////////////////////////////////////

  enum Activity
  {

    None,
    Weapons,
    Inventory,

  }

  private int mActivity;

} // class gb_Activity
