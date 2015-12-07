void main()
{
	int botx, boty;
	while(1)
	{
		fruit * cur = request_fruit();
		fruit * target = fruits;
		while(cur != NULL)
		{
			if (cur->points > target->points)
				target = cur;
			cur++;
		}
		if (target.id == Cherry)
			chasecherry(target);
		else if (target.id == Loquat)
			chaseLoquat(target);
	}

}

void chasecherry(fruit * target)
{
	if (target.y > boty)
		return;
	fruit * cur = request_fruit();
	while (cur)
	{
		if (cur->id == target->id)
			break;
	}
	if (cur == NULL)
		return;
	int k = (cur->y - target->y) / (cur->x - target->x);
	int x = (botx - cur->x) / k + botx;
	gotox(x);

}