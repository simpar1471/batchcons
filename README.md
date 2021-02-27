# batchcons: Call the TOPCONS WSDL API from R.
## Overview
The functions in this script allow a user to either submit or retrieve jobs from the [TOPCONS web server](https://topcons.net/pred/) using R. Requires the R packages <b>glue</b> (available from the CRAN [alone](https://cran.r-project.org/web/packages/glue) or as part of the [tidyverse](https://cran.r-project.org/web/packages/tidyverse/)) and <b>stringr</b> (available from the [CRAN](https://cran.r-project.org/web/packages/stringr)), and a <b>Python installation</b> (available from the [Python website](https://www.python.org/downloads/)) if you're submitting jobs.<br/><br/>Credit for [TOPCONS: The TOPCONS web server for combined membrane protein topology and signal peptide prediction.](https://pubmed.ncbi.nlm.nih.gov/25969446/) Tsirigos KD, Peters C, Shu N, Käll L and Elofsson A (2015) Nucleic Acids Research 43 (Webserver issue), W401-W407. Credit for `batch_wsdl.py`: [Nanjiang Shu](https://www.su.se/english/profiles/nash2920-1.188205).
## Usage
### <b>Step 1:</b>
First, run `batchcons.R` to load its functions into your current R environment. Next, fetch the `batch_wsdl.py` script (if you don't have it already) from the TOPCONS website using the `downloadTOPCONSScript()` function:
```R
wsdl_path <- file.path("wsdl_dir","batch_wsdl.py")
downloadTOPCONSScript(wsdl_path)
```
### <b>Step 2: Submit or fetch TOPCONS jobs:</b> 
#### <b>Submit a TOPCONS job:</b>
To submit a topcons job, use the `submitTOPCONS()` function. The function requires a path to a suitable Python exe, the batch_wsdl.py script, and a `.txt` file in the <b>FASTA format</b>. An example FASTA input is given below. You can generate FASTA files like those needed here in R using UniprotR's GetSequences() function and glue().<sup>see below!</sup> You may also provide a job name for your submission, and an email address. This email address will receive a notification when the TOPCONS web server has finished analysing your submitted sequences. Make sure to record the job ID, which will be logged in the console.
##### <b>Example of input file:</b>
``` txt
>Adgrf2
MIPAHWLYCLMLLLPIESCRILCQASSKSKEKVTSRPHDVCDGVCNNNGTPCFQSCPPDSEGNMKFACKAKKWHKVTETCHTLNTHSIFEEDKELYSVQSSDSTIRTHMFHRELKTIMDTLMEKCPKDLSCVIKGIERSPRMPGNIAVVVQLLHNISTTLTKDVNEEKMQSYSAMANHILNSKSISNWTFIQDRNSSCVLLQSIHSFASKLFMKEHLINISHVFIHTLGTVVSRGSLGKNFTFSMRINETSDKVTGRLLLSPEELQKVPSAFQVISIAFPTLGAILEASLLENVTVNGLVLSVILPEELKNISLIFEKIRKSGERKSQCVGWHSLESRWDWRACKTIQENSRQAVCRCRPNKLYTSFSILMSPNTLESPVLTYITYIGLGISICSLIICLAIEVLVWSQVTKTEISYLRHLCIANIAATLLMADAWFIVASFLSGPVLHHNGCVAATFFVHFFYLSVFFWMLAKALLILYGILIVFHTLPKSCLVASLFSVGYGCPLVIAIITLAVTEPGKGYLRPEACWLNWDMTKALLAFVVPALAIVVVNLITVTMVIIKTQRAAIGSSMFQEVRAIVRICKNIAILTPLLGLTWGFGIATVINGHSLAFHIIFSLLNALQVSPDAAVDSELRECVHRFCG
>Adgrv1
MSVTSEPGMISSFLLVYLSTLFISFVFGEAEIRFTGQTEFFVNETSTTVIRLVIERIGEPANVTAIVSLSGEDTGDFFDTYAAAFIPARGTNRTVYIAVCDDDLPEPDETFTFHLTLQKPSANVKLGWPRAASVTILSNDNAFGIISFSTPSSISVIEPRSRNASVPLTLIREKGTYGMVTVTFDVSGGPNPPEEDLNPVRGNITFPPGRATVIYNVTVLDDEVPENDELFLIQLRSVEGGAEINASRSSVEIIVKKNDSPVNFMQSVYVVPEDDHVLTIPVLRGKDSDGNLIGSDETQVSIRYKVMTWDSTAHAQQNVDFIDLQPDTTLVFPPFVHESHLKFQIIDDLIPEIAESFHIMLLKNTLQGDAVLMGPSTVQVTIKPNDKPYGVLSFNSILFERPVIIDEDTASRYNLL
```
##### <b>Example of submission request:</b>
```R
python_path <- file.path("python_dir","python.exe")
wsdl_script_path <- file.path("wsdl_dir","batch_wsdl.py")
fasta_path <- file.path("topcons_inputs","my_fasta_file.txt")
jobname <- "githubRun"
email <- "dummyemail@example.com"
submitTOPCONS(python.path = python_path, 
              topcons.wsdl.path = wsdl_script_path 
              fasta.path = fasta_path, 
              job.name = jobname, 
              email.address = email)
```
#### <b>Fetch TOPCONS jobs:</b>
##### <b>Method 1: `fetchTOPCONS()`</b>
`fetchTOPCONS()` requires a path to a suitable Python .exe, the batch_wsdl.py script, a directory for its outputs, and a job ID. The output directory will receive a folder named after the job id.. Users can choose whether to extract `query.result.txt` (which contains all the prediction information, sans additional less useful data) from the zipped folder downloaded by fetchTOPCONS by setting the value of `extract.results`, which defaults to `FALSE`.
```R
python_path <- file.path("python_dir","python.exe")
wsdl_script_path <- file.path("wsdl_dir","batch_wsdl.py")
output_dir <- file.path("topcons_outputs")
job_id <- "rst_12tESt34"
fetchTOPCONS(python.path = python_path, 
              topcons.wsdl.path = wsdl_script_path 
              output.dir = output_dir, 
              job.id = job_id, 
              extract.results = FALSE)
```
If you want to extract `query.result.txt` in your own time, call `extractQueryResults()` and point it in the direction of your zipped folder. 
##### <b>Method 2: `downloadQueryResults()`</b>
Alternatively, if you only care about `query.result.txt`, you can use `downloadQueryResults()` to fetch only `query.result.txt` from the TOPCONS web server. This is far less bandwidth-intensive than downloading the entire zipped folder for a given job (e.g. for 729 sequences: a <b>~6.58 MB text file</b> versus a <b>~120 MB zipped folder</b>) .
### <b>Step Three: Reap the fruits of TOPCONS' labour.</b>
The output file, `query.results.txt` can be parsed to extract useful information. The zipped folder  contains more information, including graphical representations of your sequences' predicted topology.
## <b>Issues/Bug Reports/Requests</b>
If you have any problems, drop them on the [issues page](https://github.com/simpar1471/batchcons/issues). This script was written on Windows, so it's posible that there are some incompatibilities with Linux/Mac OS. I don't have the facilities to test whether this is the case.
### <b>Common Errors</b>
The most common error is caused by a splintering of the Python package `urllib` into multiple modules after `batch_wsdl.py` was written. This splintering causes calls to `urllib` to fail when Python is more recent. If this occurs, the R console will log:
```
AttributeError: module 'urllib' has no attribute 'urlretrieve'
````
If this occurs, run `updateTOPCONSScript()`, which replaces calls to `urllib` in `batch_wsdl.py` with calls to `urllib.request`:
```R
wsdl_script_path <- file.path("wsdl_dir","batch_wsdl.py")
updateTOPCONSScript(topcons.wsdl.path) 
```
## <b>Preparing FASTA sequences</b>
You can easily prepare your own FASTA sequences if you have some Uniprot identifiers, and install `UniprotR` and the `tidyverse`:
```R
if(!require(glue)) install.packages("glue"); library(glue)
if(!require(UniprotR)) install.packages("UniprotR"); library(UniprotR)
if(!require(tidyverse)) install.packages("tidyverse"); library(tidyverse)

uniprot_df <- data.frame(c("Q8VGY1", "O08707", "P56485", "Q924I3")) %>%
  dplyr::rename(uniprotAC = c..Q8VGY1....O08707....P56485....Q924I3..)
output_path <- file.path("data", "fasta_folder","myFASTA.txt")
saveFASTA <- function(dataframe.uniprots, output.path)
{
  new_seqs <- dataframe.uniprots$uniprotAC %>%
    UniprotR::GetSequences() %>%
    tibble::rownames_to_column("uniprotAC") %>%
    dplyr::select(uniprotAC, Sequence) %>%
    dplyr::rename(protSequence = Sequence) # Dataframe with uniprot IDs and peptide sequences
  fasta_vec <- glue(">{new_seqs$uniprotAC}\n{new_seqs$protSequence}")
  write(fasta_vec, file = output.path)
}
saveFASTA(uniprot_df, output_path)
```
This gives an output file in FASTA format:
```txt
>Q8VGY1
MGGEAHNSSGLPPFILTGLPGMETSQHWLFLLLGVLYTVSIVGNALILFIIKEEESLHQPMYYFLSLLSLNDLGVSFSTLTTVLGVFCFLLREISFNSCMSQMFFIHLFSFMESGILLAMSFDRYVAICNPLHYSTVLTDARVMWMGVCVFFRSFCMIFPLPFLLKRLPFCKANVLSHAYCLHPDMIRLPCGDITINNIFGLFIVISTFGLDSALILLSYVLILRSVLAIASREERLKTLNTCVSHLCAVLIFYVPMVGVSMAARYGRHAPRYVHTLLSLVYLFVPPMLNPVIYSIKTKEIRRRLHKILLGTKI
>O08707
MPTVASPLPLTTVGSENSSSIYDYDYLDDMTILVCRKDEVLSFGRVFLPVVYSLIFVLGLAGNLLLLVVLLHSAPRRRTMELYLLNLAVSNLLFVVTMPFWAISVAWHWVFGSFLCKVISTLYSINFYCGIFFITCMSLDKYLEIVHAQPLHRPKAQFRNLLLIVMVWITSLAISVPEMVFVQIHQTLDGVWHCYADFGGHATIWKLYLRFQLNLLGFLLPLLAMIFFYSRIGCVLVRLRPPGQGRALRMAAALVIVFFMLWFPYNLTLFLHSLLDLHVFGNCEISHRLDYTLQVTESLAFSHCCFTPVLYAFCSHRFRRYLKAFLSVMLRWHQAPGTPSSNHSESSRVTAQEDVVSMNDLGERQSEDSLNKGEMGNT
>P56485
MDVHLFDYAEPGNYSDINWPCNSSDCIVVDTVQCPTMPNKNVLLYTLSFIYIFIFVIGMIANSVVVWVNIQAKTTGYDTHCYILNLAIADLWVVITIPVWVVSLVQHNQWPMGELTCKITHLIFSINLFGSIFFLACMSVDRYLSITYFTGTSSYKKKMVRRVVCILVWLLAFFVSLPDTYYLKTVTSASNNETYCRSFYPEHSIKEWLIGMELVSVILGFAVPFTIIAIFYFLLARAMSASGDQEKHSSRKIIFSYVVVFLVCWLPYHFVVLLDIFSILHYIPFTCQLENVLFTALHVTQCLSLVHCCVNPVLYSFINRNYRYELMKAFIFKYSAKTGLTKLIDASRVSETEYSALEQNTK
>Q924I3
MALELNQSAEYYYEENEMNYTHDYSQYEVICIKEEVRQFAKVFLPAFFTVAFVTGLAGNSVVVAIYAYYKKQRTKTDVYILNLAVADLLLLITLPFWAVNAVHGWILGKMMCKVTSALYTVNFVSGMQFLACISIDRYWAITKAPSQSGAGRPCWIICCCVWMAAILLSIPQLVFYTVNQNARCTPIFPHHLGTSLKASIQMLEIGIGFVVPFLIMGVCYASTARALIKMPNIKKSRPLRVLLAVVVVFIVTQLPYNVVKFCQAIDAIYLLITSCDMSKRMDVAIQVTESIALFHSCLNPILYVFMGASFKNYIMKVAKKYGSWRRQRQNVEEIPFDSEGPTEPTSSFTI
```
