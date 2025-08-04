#include <iostream>
#include <cmath>

using namespace std;

int main()
{
	cout << "sin = " << endl;
    for (int i = 0; i < 360; i++)
    {
    	float trig = sinf((float)i * (M_PI/180.0));
    	int  inDegrees = trig * (180.0/M_PI);
        cout << inDegrees << ", ";
    }
    cout << endl;
	cout << "cos = " << endl;
	
    for (int i = 0; i < 360; i++)
    {
        float trig = cosf((float)i * (M_PI/180));
    	int  inDegrees = trig * (180.0/M_PI);
    	
        cout << inDegrees << ", ";
    }    
    cout << endl;
	    
    return 0;
}
