
diameter = 16;
wallThickness = 4;
height = 8;
seed = round(getNextRand(10000));

heightVariation = 4; // height adder
fillPossibility = 0.4; // 0-1 possibility of filling a hexagon

echo (str("SEED: ", seed));

function getNextRand(limit = 1, seed = -1) = 
	getNextRandMulti(1, limit, seed)[0];
function getNextRandMulti(count, limit = 1, seed = -1) = 
	limit == 0 ? 0 : (seed == -1 ? rands(0, limit, count) : rands(0, limit, count, seed));

function getDataPoint(data, x, y) =
	let (xClipped = x < 0 || x >= len(data) ? undef : x)
	let (yClipped = xClipped == undef ? undef : (y < 0 || y >= len(data[xClipped]) ? undef : y))
	xClipped == undef || yClipped == undef ? undef : data[x][y];

function getLimiters(data, x, y) = 
	[for (xx = [x - 1:x + 1]) (for (yy = [y - 1:y + 1]) getDataPoint(data, xx, yy))];

module hexFilled(height, diameter = diameter)
{
	cylinder(height, d1 = diameter, d2 = diameter, $fn = 6);
}

module hexPartialFilled(height, diameter = diameter, wallThickness = wallThickness)
{
	difference()
	{
		hexFilled(height, diameter + wallThickness / 2);
		translate([0, 0, height - height / 8])
			hexFilled(height * 2, diameter - wallThickness / 2);
	}
}

module hex(height, diameter = diameter, wallThickness = wallThickness)
{
	difference()
	{
		hexFilled(height, diameter + wallThickness / 2);
		translate([0, 0, -.1])
			hexFilled(height * 3, diameter - wallThickness / 2);
	}
}

module fillHex(height, seed, diameter = diameter, wallThickness = wallThickness)
{
	scale = .50;
	subDiameter = diameter * scale;
	subThickness = wallThickness * scale;

	xOffset = subDiameter * .75;
	yOffset = sqrt(3) / 2 * subDiameter;
	rep = (diameter / subDiameter) + 1;

	x1 = -(diameter * .75) / 2;
	y1 = -(sqrt(3) / 2 * diameter) / 2;

	translate([x1, y1, 0])
	union()
	{
		for (x = [0:rep - 1])
		{
			for (y = [0:rep - 1])
			{
				x2 = x * xOffset;
				y2 = y * yOffset + (x % 2) * (yOffset / 2);

				nextSeed = getNextRandMulti(4, 1, seed + x * (len(data) - 1) + y);
				isEdge = x == 0 || x == rep - 1 || y == 0 || y == rep - 1;
				if (!isEdge || nextSeed[0] < 0.5)
				{
					translate([x2, y2, 0])
					{
						if (nextSeed[1] <= fillPossibility)
							hexPartialFilled(height + heightVariation * nextSeed[2], subDiameter, subThickness);
						else
							hex(height + heightVariation * nextSeed[3], subDiameter, subThickness);
					}
				}
			}
		}
	}
}

module buildLimiters(data, height, offset)
{
	for (x = [0:2])
	{
		for (y = [0:2])
		{
			value = data[x * 3 + y];
			if ((value == 1) && (x != 1 || y != 1))
			{
				translate([x * xOffset, y * yOffset - (yOffset * offset) + ((x * (offset == 1 ? 1 : -1)) % 2) * (yOffset / 2), 0])
				{
					hexFilled(height);
				}
			}
		}
	}
}

module buildFromData(data, height, seed, triggerValue, fill = false)
{
	union()
	{
		for (x = [0:len(data) - 1])
		{
			for (y = [0:len(data[x]) - 1])
			{
				translate([x * xOffset, y * yOffset + (x % 2) * (yOffset / 2), 0])
				{
					value = data[x][y];
					nextSeed = getNextRandMulti(4, 1, seed + x * (len(data) - 1) + y);
					if (value == 1)
					{
						if (fill)
						{
							hexFilled(height);
						}
						else
						{
							if (nextSeed[0] <= fillPossibility)
								hexPartialFilled(height + heightVariation * nextSeed[0]);
							else
								hex(height + heightVariation * nextSeed[1]);
						}
					}
					else if (value == 2)
					{
						difference()
						{
							fillHex(height - heightVariation, nextSeed[3]);
							translate([-xOffset, -yOffset / 2, -.01])
								buildLimiters(getLimiters(data, x, y), height * 2, x % 2);
						}
					}
				}
			}
		}
	}
}

xOffset = diameter * .75;
yOffset = sqrt(3) / 2 * diameter;
translate([-len(data) * xOffset / 2, -len(data[0]) * yOffset / 2, 0])
	buildFromData(data, height, seed, 1);
