//
//  Program.cs
//
//  Author:
//       Jarl Gullberg <jarl.gullberg@gmail.com>
//
//  Copyright (c) 2016 Jarl Gullberg
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

using System.IO;
using Warcraft.BLP;
using System.Drawing;
using System.Drawing.Imaging;

namespace BLPThumbnailer
{
	class MainClass
	{
		public static void Main(string[] args)
		{
			string desiredSize = args[0];
			string imagePath = args[1];
			string outputPath = args[2];

			BLP image = new BLP(File.ReadAllBytes(imagePath));
			Bitmap thumbnail = image.GetBestMipMap(uint.Parse(desiredSize));

			thumbnail.Save(outputPath, ImageFormat.Png);		
		}
	}
}
