# batchcons.R - Simon Parker
# Requires the batch_wdsl.py file available from https://topcons.net/pred/help-wsdl-api/, copyright Nanjiang Shu. 

library(glue)

# Submits a FASTA file to the TOPCONS2 web server.
submitTOPCONS <- function(python.path = "", topcons.wsdl.path = "", fasta.path = "", job.name = "", email.address = "")
{
  if(missing(python.path)) stop("You're missing a file path to a Python exe.")
  if(!file.exists(python.path)) stop("The path to your Python exe is invalid.")
  if(missing(topcons.wsdl.path)) stop("You're missing a path to topcons2_wsdl.py. If you do not have it, download from https://topcons.cbr.su.se/static/download/script/topcons2_wsdl.py")
  if(!file.exists(topcons.wsdl.path)) stop("The path to topcons2_wsdl.py is invalid.")
  if(missing(fasta.path)) stop("You must provide a directory to save the TOPCONS results to.")
  if(!file.exists(fasta.path)) stop("The path to your FASTA file is invalid.")
  if(missing(job.name)) { message("This TOPCONS submission will have no job name.")
  } else message(glue("This TOPCONS job has the name {job.name}."))
  if(missing(email.address)) { message("A reminder email will not be sent once this job is finished.")
  } else message(glue("A reminder email will be sent to {email.address} once this job is completed."))

  if(missing(job.name)) { submit_cmd <- glue('"{normalizePath(python.path)}" "{normalizePath(topcons.wsdl.path)}" -m submit -seq "{normalizePath(fasta.path)}" -email {email.address}')
  } else { submit_cmd <- glue('"{normalizePath(python.path)}" "{normalizePath(topcons.wsdl.path)}" -m submit -seq "{normalizePath(fasta.path)}" -jobname {job.name} -email {email.address}') }

  sys_output <- system(submit_cmd)
  print(sys_output)
}

# Retrieves job results from the TOPCONS2 web server. If the job is completed, the query.result.txt file is retrieved from the .zip folder. The
# zipped folder is then either deleted or kept based on the value of remove.zip.  
fetchTOPCONS <- function(python.path = "", topcons.wsdl.path = "", output.dir = "", job.id = "", remove.zip = TRUE)
{
  if(missing(python.path)) stop("You must supply a normalised file path to a Python exe.")
  if(!file.exists(python.path)) stop("The path to your Python exe is invalid.")
  if(missing(topcons.wsdl.path)) stop("You must provide a path to topcons2_wsdl.py. If you do not have it, download from https://topcons.cbr.su.se/static/download/script/topcons2_wsdl.py")
  if(!file.exists(topcons.wsdl.path)) stop("The path to topcons2_wsdl.py is invalid.")
  if(missing(output.dir)) stop("You must provide a directory to save the TOPCONS results to.")
  if(!file.exists(output.dir)) stop("The specified output directory does not exist.")
  if(missing(job.id)) stop("You must provide a job ID when fetching TOPCONS results.")

  fetch_cmd <- glue('"{normalizePath(python.path)}" "{normalizePath(topcons.wsdl.path)}" -m get -jobid {job.id} -outpath "{normalizePath(output.dir)}"')
  sys_output <- system(fetch_cmd, intern = TRUE)
  print(sys_output)
  zip_path <- file.path(output.dir, glue("{job.id}.zip"))
  if(file.exists(zip_path))
  {
    query_result_path <- file.path(job.id,"query.result.txt")
    utils::unzip(zipfile = zip_path,
                 files = query_result_path,
                 exdir = output.dir)
    if(remove.zip) file.remove(zip_path)
    message(glue("TOPCONS results fetched and placed in {file.path(output.dir, job.id)}"))
  }
  else(message("Wait for your TOPCONS job to finish running."))
}
