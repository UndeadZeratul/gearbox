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

class gb_WheelView
{

  static
  gb_WheelView from()
  {
    let result = new("gb_WheelView");

    result.setAlpha(1.0);
    result.setBaseColor(0x2222CC);

    [result.mCenterX, result.mCenterY] = gb_WheelCenter.getCoordinates();

    return result;
  }

  void setAlpha(double alpha)
  {
    mAlpha = alpha;
  }

  void setBaseColor(int color)
  {
    mBaseColor = color;
  }

  void display( gb_ViewModel viewModel
              , gb_WheelControllerModel controllerModel
              , bool showPointer
              ) const
  {
    {
      TextureID circleTexture = TexMan.checkForTexture("gb_circ", TexMan.Type_Any);
      Screen.drawTexture( circleTexture
                        , NO_ANIMATION
                        , mCenterX
                        , mCenterY
                        , DTA_FillColor    , mBaseColor
                        , DTA_AlphaChannel , true
                        , DTA_Alpha        , mAlpha
                        , DTA_CenterOffset , true
                        );
    }

    uint nWeapons = viewModel.tags.size();
    int  radius   = Screen.getHeight() * 5 / 32;
    int  allowedWidth = Screen.getHeight() * 3 / 16 - MARGIN * 2;

    bool multiWheelMode = (nWeapons > 12);

    if (multiWheelMode)
    {
      Array<bool> isWeapon;
      Array<int>  data; // slot or weapon index

      int lastSlot = -1;

      for (uint i = 0; i < nWeapons; ++i)
      {
        int  slot     = viewModel.slots[i];
        bool isSingle = isSingleWeaponInSlot(viewModel, nWeapons, slot);
        if (isSingle)
        {
          isWeapon.push(true);
          data.push(i);
        }
        else
        {
          if (slot != lastSlot)
          {
            lastSlot = slot;
            isWeapon.push(false);
            data.push(slot);
          }
        }
      }

      uint nPlaces = isWeapon.size();
      for (uint i = 0; i < nPlaces; ++i)
      {
        if (isWeapon[i]) displayWeapon(i, data[i], nPlaces, radius, allowedWidth, viewModel);
        else             displaySlot  (i, data[i], nPlaces, radius);
      }
    }
    else
    {
      for (uint i = 0; i < nWeapons; ++i)
      {
        displayWeapon(i, i, nWeapons, radius, allowedWidth, viewModel);
      }

      if (mAlpha == 1.0) drawHands(nWeapons, viewModel.selectedWeaponIndex);
    }

    if (mAlpha == 1.0 && showPointer) drawPointer(controllerModel.angle, controllerModel.radius);
  }

// private: ////////////////////////////////////////////////////////////////////////////////////////

  private static
  bool isSingleWeaponInSlot(gb_ViewModel viewModel, uint nWeapons, int slot)
  {
    int nWeaponsInSlot = 0;
    for (uint i = 0; i < nWeapons; ++i)
    {
      nWeaponsInSlot += (viewModel.slots[i] == slot);
      if (nWeaponsInSlot > 1) return false;
    }
    return true;
  }

  private
  void displayWeapon( uint place
                    , uint weaponIndex
                    , uint nPlaces
                    , int  radius
                    , int  allowedWidth
                    , gb_ViewModel viewModel
                    )
  {
    double angle = itemAngle(nPlaces, place);

    int x = int(round( sin(angle) * radius + mCenterX));
    int y = int(round(-cos(angle) * radius + mCenterY));

    // code is adapted from GZDoom AltHud.DrawImageToBox.
    TextureID weaponTexture = viewModel.icons[weaponIndex];
    Vector2   weaponSize    = TexMan.getScaledSize(weaponTexture) * 2;
    bool      isTall        = (weaponSize.y > weaponSize.x);

    double scale = isTall
      ? ((allowedWidth < weaponSize.y) ? allowedWidth / weaponSize.y : 1.0)
      : ((allowedWidth < weaponSize.x) ? allowedWidth / weaponSize.x : 1.0)
      ;

    int weaponWidth  = int(weaponSize.x * scale);
    int weaponHeight = int(weaponSize.y * scale);

    drawWeapon(weaponTexture, x, y, weaponWidth, weaponHeight, angle, isTall);
  }

  private
  void displaySlot(uint place, int slot, uint nPlaces, int radius)
  {
    double angle = itemAngle(nPlaces, place);

    int x = int(round( sin(angle) * radius + mCenterX));
    int y = int(round(-cos(angle) * radius + mCenterY));

    drawText(string.format("%d", slot), x, y);
  }

  private static
  double itemAngle(uint nItems, uint index)
  {
    return 360.0 / nItems * index;
  }

  private
  void drawHands(uint nWeapons, uint selectedIndex)
  {
    if (nWeapons < 2) return;

    double handsAngle = -itemAngle(nWeapons, selectedIndex);

    TextureID handTexture = TexMan.checkForTexture("gb_hand", TexMan.Type_Any);
    double sectorAngleHalfWidth = 360.0 / 2.0 / nWeapons - 2;
    Screen.drawTexture( handTexture
                      , NO_ANIMATION
                      , mCenterX
                      , mCenterY
                      , DTA_CenterOffset , true
                      , DTA_KeepRatio    , true
                      , DTA_Alpha        , mAlpha
                      , DTA_Rotate       , handsAngle - sectorAngleHalfWidth
                      );
    Screen.drawTexture( handTexture
                      , NO_ANIMATION
                      , mCenterX
                      , mCenterY
                      , DTA_CenterOffset , true
                      , DTA_KeepRatio    , true
                      , DTA_Alpha        , mAlpha
                      , DTA_Rotate       , handsAngle + sectorAngleHalfWidth
                      );
  }

  private
  void drawPointer(double angle, double radius)
  {
    int x = int(round( sin(angle) * radius + mCenterX));
    int y = int(round(-cos(angle) * radius + mCenterY));
    TextureID pointerTexture = TexMan.checkForTexture("gb_pntr", TexMan.Type_Any);
    Screen.drawTexture( pointerTexture
                      , NO_ANIMATION
                      , x
                      , y
                      , DTA_CenterOffset , true
                      , DTA_Alpha        , mAlpha
                      );
  }

  private
  void drawWeapon(TextureID texture, int x, int y, int w, int h, double angle, bool isTall) const
  {
    bool flipX = (angle > 180);
    if (flipX) angle -= 180;
    angle = -angle + 90;

    if (isTall) angle -= 90;

    Screen.drawTexture( texture
                      , NO_ANIMATION
                      , x
                      , y
                      , DTA_CenterOffset , true
                      , DTA_KeepRatio    , true
                      , DTA_DestWidth    , w
                      , DTA_DestHeight   , h
                      , DTA_Alpha        , mAlpha
                      , DTA_Rotate       , angle
                      , DTA_FlipX        , flipX
                      );

    Screen.drawTexture( texture
                      , NO_ANIMATION
                      , x
                      , y
                      , DTA_CenterOffset , true
                      , DTA_KeepRatio    , true
                      , DTA_DestWidth    , w
                      , DTA_DestHeight   , h
                      , DTA_Alpha        , mAlpha * 0.3
                      , DTA_FillColor    , mBaseColor
                      , DTA_Rotate       , angle
                      , DTA_FlipX        , flipX
                      );
  }

  private
  void drawText(string aString, int x, int y)
  {
    x -= bigFont.stringWidth(aString) * TEXT_SCALE / 2;
    y -= bigFont.getHeight()          * TEXT_SCALE / 2;
    Screen.drawText( bigFont
                   , Font.CR_WHITE
                   , x
                   , y
                   , aString
                   , DTA_Alpha  , mAlpha
                   , DTA_ScaleX , TEXT_SCALE
                   , DTA_ScaleY , TEXT_SCALE
                   );
  }

  const NO_ANIMATION = 0; // == false

  const MARGIN = 4;

  const TEXT_SCALE = 3;

  private double mAlpha;
  private color mBaseColor;
  private int mCenterX;
  private int mCenterY;

} // class gb_WheelView
