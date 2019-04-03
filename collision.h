#pragma once

#include <iostream>
#include <vector>

//enemy position starts at the front, left, bottom

//IMPORTANT NOTE:
//using unsigned integers we can use wrapping to decrease if statements
bool collision_line_enemy(int lx,int ly,int lbz,int lez,
							int cx,int cy,int cz, int sx,int sy,int sz){
	//Line back is behind enemy front
	if (lez > cz){
		//Line front is in front of enemy back, thus there's an overlap in the Z axis
		if (lbz-cz < sz) {
			if ((unsigned int)(lx-cx) <= sx){
				if ((unsigned int)(ly-cy) <= sy) {
					return true;
				}
			}
		}
	}
	return false;
}
bool collision_line_enemy_xy(int lx, int ly,
							int cx, int cy, int sx, int sy) {
	if ((unsigned int)(lx - cx) <= sx) {
		if ((unsigned int)(ly - cy) <= sy) {
			return true;
		}
	}
	return false;
}

//player position starts at the front, left, bottom

//IMPORTANT NOTE:
//for simplification we use the xy values of the line end at the line begin as well
bool collision_line_player(int lx, int ly, int lbz, int lez,
	int cx, int cy, int cz, int sx, int sy, int sz) {
	//Line back is behind player front
	if (lez < cz) {
		//Line front is in front of play back, thus there's an overlap in the Z axis
		if (lbz - cz < sz) {
			if ((unsigned int)(lx - cx) <= sx) {
				if ((unsigned int)(ly - cy) <= sy) {
					return true;
				}
			}
		}
	}
	return false;
}



struct Entity {
	int cx, cy, cz, sz, sy, sz, spd;
};

struct BulletPlayer {
	int x, y, z, zprev, spd;
};

void collision_manager_compact(std::vector<Entity>& enemies, std::vector<BulletPlayer>& bullets) {
	int curbul, curen;
	curbul = bullets.size()-1;
	curen = 0;

	while (curbul >= 0 && curen < enemies.size()) {
		//If true, the front of the bullet past the front of the enemy
		if (bullets[curbul].z >= enemies[curen].cz){
			//If true, there's an overlap on the Z axis
			if (bullets[curbul].zprev - enemies[curen].cz < enemies[curen].sz) {
				//If true, there's a collision between the bullet and the enemy, destroy them both and move to the next bullet and enemy (curen stays the same because of vector reshaping)
				if (collision_line_enemy_xy(bullets[curbul].x, bullets[curbul].y, enemies[curen].cx, enemies[curen].cy, enemies[curen].cx, enemies[curen].cy)) {
					bullets.erase(bullets.begin + curbul);
					enemies.erase(enemies.begin + curen);

					curbul--;
				}
				//If false, there's no collision so we move on to the next bullet (we assume that the enemies have a big enough stride between them that the bullet doesn't overlap with 2 enemies on the Z-axis at the same time)
				else {
					curbul--;
				}
			}
			//If false, the bullet has passed the enemy, move to the next enemy
			else {
				curen++;
			}
		}
		//If false, the bullet can't reach the next enemy, move to the next player
		else {
			curbul--;
		}
	}
}