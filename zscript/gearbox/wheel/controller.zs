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

class gb_WheelController
{

  static
  gb_WheelController from(gb_Options options)
  {
    let result = new("gb_WheelController");

    result.mIsActive = false;
    result.reset();
    result.mScreen   = gb_Screen.from();
    result.mOptions  = options;

    return result;
  }

  void reset()
  {
    mX = 0;
    mY = 0;
  }

  void setIsActive(bool isActive)
  {
    mIsActive = isActive;

    if (mIsActive) reset();
  }

  void fill(out gb_WheelControllerModel model)
  {
    model.angle  = getAngle();
    model.radius = getRadius();
  }

  bool process(InputEvent event)
  {
    if (!mIsActive || event.type != InputEvent.Type_Mouse) return false;

    mMouseSensitivity = mOptions.getMouseSensitivity();

    mX += int(round(event.mouseX * mMouseSensitivity.x));
    mY -= int(round(event.mouseY * mMouseSensitivity.y));

    vector2 center = mScreen.getWheelCenter();
    int centerX = int(center.x);
    int centerY = int(center.y);

    mX = clamp(mX, -centerX, Screen.getWidth()  - centerX);
    mY = clamp(MY, -centerY, Screen.getHeight() - centerY);

    return true;
  }

// private: ////////////////////////////////////////////////////////////////////////////////////////

  private
  double getAngle() const
  {
    return -atan2(mX, mY) + 180;
  }

  private
  double getRadius() const
  {
    return sqrt(mX * mX + mY * mY);
  }

  private bool mIsActive;
  private int  mX;
  private int  mY;
  private Vector2 mMouseSensitivity;

  private gb_Screen  mScreen;
  private gb_Options mOptions;

} // class gb_WheelController