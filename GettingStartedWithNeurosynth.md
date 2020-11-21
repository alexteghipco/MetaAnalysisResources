This readme will take you through some analyses that you can perform in neurosynth. Some of this code can also be found in the Neurosynth [readme](https://github.com/neurosynth/neurosynth/blob/master/README.md). 

# Getting started

Okay, so first thing we'll want to do is open up a terminal window (if you're on mac) and start up python. Then, we'll want to import the neurosynth module and also the os module for some auxilary functions that will come in handy later.

	> from neurosynth import meta, decode, network, Dataset
	> import os
    
Now we need to build the Neurosynth database. To do that, we first load our dataset, which contains all of the studies within Neurosynth.

	> dataset = Dataset('/usr/local/lib/python2.7/site-packages/neurosynth/database.txt')

**Note your filepath here will vary depending on where you've installed the module, and whether you've moved/downloaded a more updated version of the dataset.*

The next step--which might take a few minutes--is to extract word frequencies from the studies we've loaded. To do that (using a previously determined set of phrases based on how Neurosynth text mines studies--phrases need to re-occur a certain number of times across studies) we pass:
 
 	> dataset.add_features('/usr/local/lib/python2.7/site-packages/neurosynth/features.txt')
  
# Making lists of studies

And that's it! Now you can start meta-analyzing. Let's say we want to pull out all of the studies that frequently use the phrase "semantic" in the Neurosynth database. In this case, we'll define "frequently" as the default according to Neurosynth, which is 1/1000 words. 

**Note in some documents, Neurosynth claims these frequencies line up with words in the abstract, in others it claims it lines up with main text frequencies. Based on testing I've done, it looks like it's the latter.*

 	> sem = dataset.get_studies('semantic', frequency_threshold=0.001)
  
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

# Basic meta-analysis

So far we haven't actually performed a meta-analysis of the lists of studies we've been retrieving. Let's do that now: 

	> baseDir = '/Users/alex/Desktop/semPhon'
 	> m = meta.MetaAnalysis(dataset, sem_minus_phon, q=0.05)
 	> m.save_results('prefix',baseDir + '/SemMinPhon')

If you navigate to the folder you've set up as baseDir, you should now see a bunch of files with different appended strings. These are the ones that are important:

* "*_consistency_z.nii.gz is the " -- this is a forward inference map that has no threshold applied
* "*_consistency_z_FDR_0.05.nii.gz is the " -- this is a forward inference map that has an FDR threshold applied based on the q variable you passed to meta.MetaAnalysis
* "*_specificity_z.nii.gz is the " -- this is an association map that has no threshold applied
* "*_specificity_z_FDR_0.05.nii.gz is the " -- this is an association map that has an FDR threshold applied based on the q variable you passed to meta.MetaAnalysis
* "*_pFgA_emp_prior.nii.gz is the " -- this is a true reverse-inference map using an empirical prior. It is not corrected. pFgA refers to probability of function (i.e,. frequently using the phrase you've queried) given activation. You'll see a map in your directory that shows the reverse relation as well. 
* "*_pFgA_emp_prior_FDR_0.05.nii.gz is the " -- this is a true reverse-inference map using an empirical prior. It is FDR corrected based on the q variable you passed to meta.MetaAnalysis
* "*_pFgA_pF=0.50.nii.gz is the " -- this is a true reverse-inference map using a uniform prior. It is not corrected.
* "*_pFgA_pF=0.50_FDR_0.05.nii.gz is the " -- this is a true reverse-inference map using a uniform prior. It is FDR corrected based on the q variable you passed to meta.MetaAnalysis

You can now load these maps into your favorite volume viewing software. If you don't have a favorite and you're interested in quickly being able to project volume space (MNI) maps into surface space, might I suggest [brainSurfer](https://github.com/alexteghipco/brainSurfer)? 

The maps you'll mostly be interested in are the corrected "specificity" (i.e., association) maps. If you project the non-FDR corrected map into volume space, you'll see something like this: 

![SemMinPhon not thresholded](https://i.imgur.com/nKo7hGy.png)

If you are working in surface space, you might want to FDR correct your image at this point. To do so, you can use the ZtoP.m file in this repository, along with some way of reading in nifti files into matlab (for example, brainSurfer will come with load_nifti.m, which is distributed with freesurfer). You can then run something like this:

 	>> baseDir = '/Users/alex/Desktop/semPhon'; % since we haven't defined the main directory we'll be working with in matlab yet
 	>> in = load_nifti([baseDir '/SemMinPhon_specificity_z_RF_ANTs_MNI152_to_fsaverage_LH.nii.gz']); % load in the nifti file
 	>> [pVec, pVecCorr, pVecQVals] = ZtoP(in.vol, 'FDR', 0.05); % the last argument is q threshold
 	>> id = find(pVecCorr >= 0.05);
	>> in.vol(id) = 0;
	>> save_nifti(in,[baseDir '/SemMinPhon_specificity_z_FDR_05_RF_ANTs_MNI152_to_fsaverage_LH.nii.gz'])

**Note ZtoP uses mafdr.m to perform FDR correction. This comes with the bioinformatics toolbox in MATLAB but you can also download any of the many FDR correction scripts out there for matlab and just change one line in ZtoP.m

Now if you load up your FDR corrected file, it should look something like this: 

![SemMinPhon thresholded](https://i.imgur.com/4gFo1kH.png)

But let's say we want to more concretely evaluate which areas are involved in semantics than phonology. To do this, we can run a contrast meta-analysis, where instead of using all studies as the comparison to our selected list of studies, we just use another list. This code will generate such an analysis: 

 	> conM = meta.MetaAnalysis(dataset, sem, phon, q=0.01)
 	> conM.save_results('prefix',base + '/SemVsPhon')

If you load up the results (association map), they might look something like this: 

![SemVsPhon](https://i.imgur.com/4FirUMT.png)

Looks like no regions are more activated for semantic studies than phonological studies. As far as phonological studies go, we see greater activity in ventral premotor cortex bleeding into the inferior frontal sulcus, the inferior parietal sulcus, and curiously two small clusters in the superior temporal gyrus: one in posterior planum temporale (area Spt?), and one in anterior-to-mid PT. This lines up nicely with the phonological network we might expect. The mid-PT activity is closer to the superior temporal sulcus and could be consistent with what phonological studies often refer to as posterior superior temporal sulcus. We might expect more activity in IFG, although it does exist (there is a teeny tiny cluster). Stronger activity in premotor cortex might reflect the fact that some semantic studies still involve phonological access, but on the whole are way less likely to use any kind of speech production tasks. 

# Other useful basic stuff

Another useful analysis you can do in Neurosynth, is to search studies based on foci. Let's say you're interested in an area of ventral premotor cortex that has a center of mass in [-52,-4,44] (MNI space). Well, we can retrieve all studies that report activity within a small 4mm radius of that point by using the following code: 

 	> prem = dataset.get_studies(peaks=[[-52, -4, 44]], r=4)
	> len(prem)

This gives us a list of 157 studies. Now, if we wanted to, we could manually comb through these studies, identify the contrasts that activated our coordinate, and then try to come up with an understanding of what computation it might support. A similar functionality is provided by other databases, but it makes the most sense to use neurosynth for this because it's by far the largest database.

Another very useful analysis in Neurosynth is to produce a coactivation map. This will tell us which other areas tend to be reported as activating in conjunction with our coordinate, across all sorts of tasks. To do this, you would run something like this: 

 	> network.coactivation(dataset, [[-52, -4, 44]], threshold=0.1, outroot='PreMCoactivation', r=4)

You could also do a similar thing with an entire ROI rather than a single coordinate. That is, look for studies that report activity near any coordinate within a region. You can even do this for multiple regions at once:

 	> ids = get_studies_by_regions(dataset,["PreMCoactivation.nii.gz", "SemMinPhon_specificity_z.nii.gz"], threshold=0.08,remove_overlap=True, studies=None,features=None, regularization="scale") 

Finally, it's also possible to decode other maps you have lying around. By default, this amounts to correlating your map with each meta-analysis. As such, this works best with unthresholded maps:

 	> decoder = decode.Decoder(dataset=dataset, method='pearson', features=None, mask=None, image_type='association-test_z', threshold=0.001)
	> r = decoder.decode('SemMinPhon_specificity_z.nii.gz', save='SemMinPhon_specificity_z_decoded.txt')
	
**Note The decoder generates each possible meta-analysis so if you don't pass in a list of specific features, it will take forever to execute that first line*

If we wanted to decode an ROI, we could do this as well. The decoder will return the mean z-sore within our ROI for each feature/phrase we want analyzed

 	> decoder = decode.Decoder(dataset=dataset, method='ROI', features=None, mask=None, image_type='association-test_z', threshold=0.001)
	> r = decoder.decode('SemMinPhon_specificity_z.nii.gz', save='SemMinPhon_specificity_z_decoded.txt')

# More complex stuff you can do

So these are the basic analyses you can do in Neurosynth. But let's look at some other cool things you might try. For example, let's say you want to try to split semantic studies into different groups based on the different word frequencies they use. To do something like that you might try adding this to the snippet of matlab code from above where we extracted study info using pmids: 

 	>> fileID = fopen('/Users/alex/Downloads/current_data/features.txt'); % load in word frequencies
 	>> tmp = '%s ';
 	>> tmp2 = repmat(tmp,1,3229); % each column in the features file is a frequently used word
	>> f = textscan(fileID,tmp2,'delimiter','	');

	>> clear dCheck
	>> dCheck = str2double([f{1}]);
	>> for i = 1:length(pmid) % loop over pmids and extract their word frequencies
	>>    disp(num2str(i))
	>>    id = find(dCheck == pmid(i));
	>>    for j = 1:length(f)-1
	>>    	  studyFq(i,j) = str2double(f{j+1}(id));
	>>    end
	>> end

	>> for j = 1:length(f)-1 
	>>     feat{j} = f{j+1}{1};
	>> end

The rows of studyFq index each study you've retrieved, and the cols index the frequency of each word in the study. You might want to do some other processing to this matrix, but it's now effectively possible to cluster studies together using their word frequencies. Maybe you might try something like k-means: 

	>> [IDX, C] = kmeans(studyFq, 2)
	
By the way, if you're annoyed by having to copy in the pmids from python/bash into matlab, a more elegant solution might be to save the pmids for each phrase you're interested in analyzing into a text file that you can reference later or load in automatically from matlab. This code would do that for you: 

	> for keyterm in your_list: # make sure you put all the phrases you want to loop through into your_list. To extract all features from neurosynth, you can use: dataset.get_feature_names()
	>     print(keyterm)
	>     ids = dataset.get_studies(features=keyterm,frequency_threshold=0.001,activation_threshold=0.0, r=4)
	>     outName = baseDir + '/' + keyterm[0] + '_ids.txt'
	>     f = open(outName, "w")
	>     ids = str(ids)
	>     f.write(ids[1:-1])
	>     f.close()

Maybe instead of clustering words, we want to cluster meta-analyses themselves. Or maybe we'd just like to precompute all of the meta-analysis files so that we never have to regenerate them on the fly. To do something like that, you can run the following: 

	> outFold = '/Volumes/HICKOK-LAB/NS_metas'
	> outExt = '.nii.gz'
	> os.mkdir(outFold)
	> feature_list = dataset.get_feature_names()
	> for i in feature_list:
 	>     print(i)
 	>     id = dataset.get_studies(i, frequency_threshold=0.001)
 	>     m = meta.MetaAnalysis(dataset, id, q=0.01)
 	>     fOut = outFold + '/' + i + outExt
	>     print(fOut)
	>     m.save_results('.', fOut)
    
I typically work with the whole NS database in matlab, which you can prepare with the following code once you've produced all of your meta-analyses: 

	>> cd('/Volumes/HICKOK-LAB/NS_metas')
	>> % load in a brain mask first so you aren't wasting your hard drive space by storing empty space
	>> tmp = load_nifti('/usr/local/fsl/data/standard/MNI152_T1_2mm_brain_mask.nii.gz');
	>> coBrain = find(tmp.vol ~= 0);

	>> % we'll be using load_nifti, which will have issues unzipping files if they have spaces. Unfortunately, these files do have spaces...let's loop through all files and fix that
	>> files = dir('*');
	>> for i = 1:length(files)
	>>     disp(['Working on file ' num2str(i) ' of ' num2str(length(files))])
	>>     id = strfind(files(i).name,' ');
	>>     if ~isempty(id)
	>>         oName = files(i).name;
	>>         oName(id) = '_';
	>>         movefile(files(i).name,oName)
	>>     end
	>> end

	>> % let's load in all of the association maps first (unthresholded)
	>> files = dir('*specificity_z.nii.gz');
	>> for i = 1:length(files)
	>>     disp(['Working on file ' num2str(i) ' of ' num2str(length(files))])
	>>     feat{i,1} = files(i).name(1:end-28); % this will remove the appended strings so that you can extract just the feature name
	>>     tmp = load_nifti(files(i).name);
	>>     allMetasUnthresh(:,i) = tmp.vol(coBrain);
	>> end

	>> % let's load in all of the association maps (thresholded). We should use the feature names now to make sure this new matrix cols line up with the old one
	>> for i = 1:length(feat)
	>>     disp(['Working on file ' num2str(i) ' of ' num2str(length(feat))])
	>>     tmp = load_nifti([feat{i} '.nii.gz_specificity_z_FDR_0.01.nii.gz']);
	>>     allMetasThresh(:,i) = tmp.vol(coBrain);
	>> end
	
	>> % and here's how we can load up the reverse-inference maps
	>> for i = 1:length(feat)
	>>     disp(['Working on file ' num2str(i) ' of ' num2str(length(feat))])
	>>     tmp = load_nifti([feat{i} '.nii.gz_pFgA_emp_prior.nii.gz']);
	>>     allMetasRIEmpUnthresh(:,i) = tmp.vol(coBrain);
	>> end
	>> for i = 1:length(feat)
	>>     disp(['Working on file ' num2str(i) ' of ' num2str(length(feat))])
	>>     tmp = load_nifti([feat{i} '.nii.gz_pFgA_emp_prior_FDR_0.01.nii.gz']);
	>>     allMetasRIEmpUnthresh(:,i) = tmp.vol(coBrain);
	>> end
	>> for i = 1:length(feat)
	>>     disp(['Working on file ' num2str(i) ' of ' num2str(length(feat))])
	>>     tmp = load_nifti([feat{i} '.nii.gz_pFgA_pF=0.50.nii.gz']);
	>>     allMetasRIUniUnthresh(:,i) = tmp.vol(coBrain);
	>> end
	>> for i = 1:length(feat)
	>>     disp(['Working on file ' num2str(i) ' of ' num2str(length(feat))])
	>>     tmp = load_nifti([feat{i} '.nii.gz_pFgA_pF=0.50_FDR_0.01.nii.gz']);
	>>     allMetasRIUniThresh(:,i) = tmp.vol(coBrain);
	>> end

Let's say you want to decode each meta-analysis as well. This amounts to correlating each meta-analysis with each other meta-analysis. Lots of ways you could do this. The fastest will be to load in all your meta-analyses and cross correlate them. Another might be to take advantage of the decoder function in neurosynth using something like this: 

	> os.chdir(outFold)
	> for file in glob.glob("*_pFgA_z.nii.gz"): # this is an older way neurosynth referred to association maps so you might have to change this expression so you capture the right files...
	>     print(file)
 	>     outName = file[:-7] + '_decoded.txt'
 	>     result = decoder.decode(file, save=outName)
	
And that's it! I think this more than enough to get you really started with neurosynth. There's all sorts of interesting things you can do to build on these analyses. Send me questions or comments if something isn't working and I'd be glad to help.

