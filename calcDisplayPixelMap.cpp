#include <iostream>
#include <cmath>

using namespace std;

void debugMatrix()
{
	cout << "pixel to character mapping matrix" << endl;
	unsigned short character = 0;
	for (int y = 0; y < 2 * 24; y++)
	{
		cout << "    defb " ;		
	    for (int x = 0; x < 2 * 32; x++)
	    {    		    		
			cout << character;
			if (x < (2*32) - 1) cout << "," ;
			character++;
    	}
    	cout << endl;
    }    
    cout << endl;
}



void printDisplayMatrix()
{
	cout << "pixel to character mapping matrix" << endl;
	for (int y = 0; y < 2 * 24; y++)
	{
		cout << "    defb " ;
	    for (int x = 0; x < 2 * 32; x++)
	    {
    		unsigned short character = 0;
    		// if x is even we want character 1 or 4
    		if (x % 2 == 0)
    		{
    			// x is even and y is even then we want charcter 1
    			if (y % 2 == 0)
    			{
    				character = 1;
    			}
    			else // x is even and y odd we want character 4
    			{
    				character = 4;
    			}
			}
			else // if x is odd we want character 2 or 135
			{
				// x is odd and y is even then we want charcter 2
    			if (y % 2 == 0)
    			{
    				character = 2;
    			}
    			else // x is add and y odd we want character 135
    			{
    				character = 135;
    			}
			}
			cout << character;
			if (x < (2*32) - 1) cout << "," ;		
    	}
    	cout << endl;
    }    
    cout << endl;
}

int main()
{
	printDisplayMatrix();
}
