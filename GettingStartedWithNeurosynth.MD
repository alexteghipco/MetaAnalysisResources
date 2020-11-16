This readme will take you through some analyses that you can perform in neurosynth. Some of this code can also be found in the Neurosynth [readme](https://github.com/neurosynth/neurosynth/blob/master/README.md). 

Okay, so first thing we'll want to do is open up a terminal window (if you're on mac) and start up python. Then, we'll want to import the neurosynth module and also the os module for some auxilary functions that will come in handy later.

	> from neurosynth import meta, decode, network, Dataset
	> import os
    
Now we need to build the Neurosynth database. To do that, we first load our dataset, which contains all of the studies within Neurosynth.

	> dataset = Dataset('/usr/local/lib/python2.7/site-packages/neurosynth/database.txt')

**Note your filepath here will vary depending on where you've installed the module, and whether you've moved/downloaded a more updated version of the dataset.*

The next step--which might take a few minutes--is to extract word frequencies from the studies we've loaded. To do that (using a previously determined set of phrases based on how Neurosynth text mines studies--phrases need to re-occur a certain number of times across studies) we pass:
 
 	> dataset.add_features('/usr/local/lib/python2.7/site-packages/neurosynth/features.txt')
  
And that's it! Now you can start meta-analyzing. Let's say we want to pull out all of the studies that frequently use the phrase "semantic" in the Neurosynth database. In this case, we'll define "frequently" as the default according to Neurosynth, which is 1/1000 words. 

**Note in some documents, Neurosynth claims these frequencies line up with words in the abstract, in others it claims it lines up with main text frequencies. Based on testing I've done, it looks like it's the latter.*

 	> sem = = dataset.get_studies('semantic', frequency_threshold=0.001)
  
Using the following command we can quickly check how many studies we've retrieved:

 	> len(sem)
  
If you are using the latest neurosynth database file, you should see 1031 studies. The pmid of each retrieved study is contained in the list "sem", which we can view using: 

 	> print(sem)
  
I'm a little bit more comfortable with matlab so if I've ever needed to lookup study details from this list of pmid's I've typically just copied the results of the print command into matlab and run the following:

 	>> fileID = fopen('/usr/local/lib/python2.7/site-packages/neurosynth/database.txt'); % load in the database
 	>> g = textscan(fileID,'%s %s %s %s %s %s %s %s %s %s %s %s %s','delimiter','		'); % these are the columns in the database text file
 	>> fclose(fileID)

 	>> for i = 1:length(g) % this is for removing column titles
 	>>    g{i}(1) = []; 
 	>> end

 	>> dCheck = str2double([g{1}]); % this is to convert pmids from database to numbers

 	>> pmid = []; % copy in the output of the print(sem) command in python 
 	>> for i = 1:length(pmid) % loop over studies (i.e., pmids)
 	>>    id = find(dCheck == pmid(i)); % find study in the database
 	>>    study{i,1} = string(unique(g{10}(id))); % retrieve title of study,
 	>>    study{i,2} = string(unique(g{11}(id))); % authors,
 	>>    study{i,3} = string(unique(g{12}(id))); % year,
 	>>    study{i,4} = string(unique(g{13}(id))); % journal.
 	>> end

**Note from here on out, I will refer to ">>" as matlab code and ">"as python/bash code.*

We can also perform more complex meta-analyses. For instance, let's find semantic studies that don't also frequently use the phrase "phonological":

 	> phon = dataset.get_studies('phonological', frequency_threshold=0.001)
 	> sem_minus_phon = list(set(sem) - set(phon))

Let's see how many of our original studies in the "sem" list this has removed:
	
 	> print(len(sem) - len(sem_minus_phon))
	
Looks like we've removed 134 studies. If we instead wanted to retrieve these 134 studies that frequently use the phrase "semantic" and "phonological", we would do this: 

 	> sem_and_phon = list(set(sem) & set(phon))

To get all studies either using the phrase "semantic" or "phonological" we would do this instead:

 	> sem_plus_phon = list(sem + phon)

**Note I'm saving the output as a list in a lot of these cases because it makes it easier to just paste the printed result into matlab (also I think lists are a little bit easier to work with in python). If you want to keep output saved as a set, you can.*

So far we haven't actually performed a meta-analysis of the lists of studies we've been retrieving. Let's do that now: 

	> baseDir = '/Users/alex/Desktop/semPhon'
 	> conM = meta.MetaAnalysis(dataset, sem_minus_phon, q=0.05)
 	> conM.save_results('prefix',baseDir + '/SemMinPhon')

If you navigate to the folder you've set up as baseDir, you should now see a bunch of files with different appended strings. These are the ones that are important:

* "*_consistency_z.nii.gz is the " -- this is a forward inference map that has no threshold applied
* "*_consistency_z_FDR_0.05.nii.gz is the " -- this is a forward inference map that has an FDR threshold applied based on the q variable you passed to meta.MetaAnalysis
* "*_specificity_z.nii.gz is the " -- this is an association map that has no threshold applied
* "*_specificity_z_FDR_0.05.nii.gz is the " -- this is an association map that has an FDR threshold applied based on the q variable you passed to meta.MetaAnalysis
* "*_pFgA_emp_prior.nii.gz is the " -- this is a true reverse-inference map using an empirical prior. It is not corrected. pFgA refers to probability of function (i.e,. frequently using the phrase you've queried) given activation. You'll see a map in your directory that shows the reverse relation as well. 
* "*_pFgA_emp_prior_FDR_0.05.nii.gz is the " -- this is a true reverse-inference map using an empirical prior. It is FDR corrected based on the q variable you passed to meta.MetaAnalysis
* "*_pFgA_pF=0.50.nii.gz is the " -- this is a true reverse-inference map using a uniform prior. It is not corrected.
* "*_pFgA_pF=0.50_FDR_0.05.nii.gz is the " -- this is a true reverse-inference map using a uniform prior. It is FDR corrected based on the q variable you passed to meta.MetaAnalysis

You can now load these maps into your favorite volume viewing software. If you don't have a favorite and you're interested in quickly being able to project volume space (MNI) maps into surface space, might I suggest brainSurfer? 

The maps you'll mostly be interested in are the corrected "specificity" (i.e., association) maps. If you project the non-FDR corrected map into volume space, you'll see something like this: 

![SemMinPhon not thresholded](https://ibb.co/6tGWVcZ)





