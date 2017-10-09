//============================================================================
// Name        : Test2.cpp
// Author      : William Pearse
// Version     :
// Copyright   : Your copyright notice
// Description : Hello World in C++, Ansi-style
//============================================================================

#include <iostream>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string>
#include <math.h>

using namespace std;

string GetStdOutFromCommand(string cmd) {

	string data;
	FILE * stream;
	const int max_buffer = 256;
	char buffer[max_buffer];
	cmd.append(" 2>&1");

	stream = popen(cmd.c_str(), "r");
	if (stream) {
	while (!feof(stream))
		if (fgets(buffer, max_buffer, stream) != NULL) data.append(buffer);
			pclose(stream);
		}
	return data;
}


int main() {
	string	setName = "hapmap1",
			//setName = "SIM_MIX_final.20",
			assocFile = setName+"Assoc",
			squeezeFile = setName+"Squeezed.assoc",
			scoreFile = setName+"Scores.score",
			dir = "~/Documents/HapMapTest/";

	int kFolds = 10;

/*
	cout << "!!!Start!!!" << endl;

	//system(	("gnome-terminal -x sh -c 'cd " + dir + ";"
			//"./plink --bfile "+ setName + " --assoc --allow-no-sex --out " + assocFile + "'").c_str());
	GetStdOutFromCommand("cd " + dir + "; "
			"./plink --bfile "+ setName + " --assoc --allow-no-sex --out " + assocFile);
	usleep(10000000);

	cout << "Assoc complete" << endl;
	//system(	("gnome-terminal -x sh -c 'cd " + dir + ";"
	//		"tr -s \\  < "+ assocFile + ".assoc > "+ squeezeFile + ";'").c_str());
	GetStdOutFromCommand("cd " + dir + "; "
				"tr -s \\  < "+ assocFile + ".assoc > "+ squeezeFile);

	usleep(2000000);
	//system(	("gnome-terminal -x sh -c 'cd " + dir + ";"
	//		"cut -f 3,5,11 -d\\  "+ squeezeFile + " > "+ scoreFile + ";'").c_str());
	GetStdOutFromCommand("cd " + dir + "; "
				"cut -f 3,5,11 -d\\  "+ squeezeFile + " > "+ scoreFile);

	usleep(2000000);
	//system(	("gnome-terminal -x sh -c 'cd " + dir + ";"
	//"./plink --bfile "+ setName + " --score "+ scoreFile + ";read line '").c_str());
	GetStdOutFromCommand("cd " + dir + "; "
				"./plink --bfile "+ setName + " --score "+ scoreFile);

	cout << "!!!Finish!!!" << endl;*/


	/*int numberOfLines = stoi(GetStdOutFromCommand("cd " + dir + "; wc -l < " + setName + ".fam"));
	int subsetSize1 = (numberOfLines%kFolds);
	int subsetValue1 = ceil(numberOfLines/float(kFolds));
	int subsetSize2 = abs(kFolds-subsetSize1);
	int subsetValue2 = floor(numberOfLines/float(kFolds));

	int lowerbound = 1;
	for (int i = 1; i<= kFolds; i++){
		if (i <= subsetSize1){
			GetStdOutFromCommand("cd " + dir + "; " +
							"sed -n '" + to_string(lowerbound) + "," + to_string(lowerbound + subsetValue1 -1) + "p' " + setName + ".fam > " + setName + "Family" + to_string(i) + ".fam" );
			lowerbound += subsetValue1;
		} else {
			GetStdOutFromCommand("cd " + dir + "; " +
										"sed -n '" + to_string(lowerbound) + "," + to_string(lowerbound + subsetValue2 -1) + "p' " + setName + ".fam > " + setName + "Family" + to_string(i) + ".fam" );
			lowerbound += subsetValue2;
		}
	}*/

	for (int i = 1; i<= kFolds; i++){
		string assoc = GetStdOutFromCommand("cd " + dir + "; "
				"./plink --bfile "+ setName + " --assoc --allow-no-sex --remove-fam " + setName + "Family" + to_string(i) + ".fam" + " --out " + setName + "Family" + to_string(i) + "Assoc");
		//usleep(10000000);
		cout << "Assoc " + to_string(i) + " complete: " << endl;

		string translate = GetStdOutFromCommand("cd " + dir + "; "
					"tr -s \\  < "+ setName + "Family" + to_string(i) + "Assoc" + ".assoc > "+ setName + "Family" + to_string(i) + "Squeeze");
		//usleep(2000000);
		cout << "Squeeze " + to_string(i) + " complete: " + translate << endl;

		string cut = GetStdOutFromCommand("cd " + dir + "; "
					"cut -f 3,5,11 -d\\  "+ setName + "Family" + to_string(i) + "Squeeze" + " > "+ setName + "Family" + to_string(i) + "Score");
		//usleep(2000000);
		cout << "Score " + to_string(i) + " file complete: " + cut << endl;

		string score = GetStdOutFromCommand("cd " + dir + "; "
					"./plink --bfile "+ setName + " --keep-fam " + setName + "Family" + to_string(i) + ".fam --score " + setName + "Family" + to_string(i) + "Score --out Family" + to_string(i) + "SResult");
		cout << "Result " + to_string(i) + " complete: " + score << endl;
	}

	return 0;
}
