This readme will take you through some analyses that you can perform in neurosynth. Some of this code can also be found in the Neurosynth [readme](https://github.com/neurosynth/neurosynth/blob/master/README.md). 

First thing we'll want to do is open up a terminal window (if you're on mac) and start up python. Then, we'll want to import the neurosynth module and also the os module for some auxilary functions.

	> from neurosynth import meta, decode, network, Dataset
	> import os
    
Now we need to build the Neurosynth database. To do that, we first load our dataset, which contains all of the studies within Neurosynth.

	> dataset = Dataset('/usr/local/lib/python2.7/site-packages/neurosynth/database.txt')

**Note your filepath here will vary depending on where you've installed the module, and whether you've moved/downloaded a more updated version of the dataset.*

The next step--which might take a few minutes--is to extract word frequencies from the studies we've loaded. To do that (using a previously determined set of phrases based on how Neurosynth text mines studies--phrases need to re-occur a certain number of times across studies) we pass:
 
 	> dataset.add_features('/usr/local/lib/python2.7/site-packages/neurosynth/features.txt')
  
And that's it! Now you can start meta-analyzing. Let's say we want to pull out all of the studies that frequently use the phrase "semantic" in the Neurosynth database. In this case, we'll define "frequently" as the default according to Neurosynth, which is 1/1000 words. 

 	> sem = = dataset.get_studies('semantic', frequency_threshold=0.001)
  
Using the following os command we can check how many studies we've retrieved:

 	> len(sem)
  
If you are using the latest neurosynth database file, you should see 1031. The pmid of each retrieved study is contained in the list "sem", which we can view using: 

 	> print(sem)
  
I'm a little bit more comfortable with matlab so if I've ever needed to lookup study details from this list of pmid's I'll copy the results of the print command into matlab and run the following:

 	>> fileID = fopen('/usr/local/lib/python2.7/site-packages/neurosynth/database.txt');
 	>> g = textscan(fileID,'%s %s %s %s %s %s %s %s %s %s %s %s %s','delimiter','		');
 	>> fclose(fileID)

 	>> for i = 1:length(g) % this is for removing column titles
 	>>    g{i}(1) = []; 
 	>> end

 	>> dCheck = str2double([g{1}]);

 	>> for i = 1:length(pmid)
 	>>    id = find(dCheck == pmid(i));
 	>>    study{i,1} = string(unique(g{10}(id)));
 	>>    study{i,2} = string(unique(g{11}(id)));
 	>>    study{i,3} = string(unique(g{12}(id)));
 	>>    study{i,4} = string(unique(g{13}(id)));
 	>> end

But let's say we 
