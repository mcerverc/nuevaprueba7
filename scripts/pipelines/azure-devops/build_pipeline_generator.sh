while getopts n:l:d: flag
do
    case "${flag}" in
        n) name=${OPTARG};;
        l) language=${OPTARG};;
        d) directory=${OPTARG};;
    esac
done

if test "$1" = "-h"
then
    echo ""
    echo "Generates a build pipeline on Azure DevOps from a YAML template according to the project programming language or framework."
    echo ""
    echo "Arguments:"
    echo "  -n    [Required] Name that will be set to the build pipeline."
    echo "  -l    [Required] Language or framework of the project."
    echo "  -d    [Required] Local directory of your project (the path should always be using '/' and not '\')."
    exit
fi

white='\e[1;37m'
green='\e[1;32m'

# Argument check.
if test -z "$name" || test -z "$language" || test -z "$directory"
then
    echo "Missing parameters, all flags are mandatory."
    echo "Use -h flag to display help."
    exit
fi

cd ../../..
pipelinesDirectory="${directory}/.pipelines"
pipelineFile="${pipelinesDirectory}/azure-pipelines.yml"

# Copy .pipelines and .templates into directory.
echo -e "${green}Copying .pipelines and .templates folder into your directory..."
echo -e ${white}
cp -r .pipelines ${directory}
cp -r .templates ${pipelinesDirectory}

# Especify the corresponding template.
sed -i "s/{language}/${language}/g" ${pipelineFile}

# Move into the project's directory and pushing the template into the Azure DevOps repository.
echo -e "${green}Committing and pushing to Git remote..."
echo -e ${white}
cd ${directory}
git add .pipelines -f
git commit -m "Adding build pipeline source YAML"
git push -u origin --all

# Creation of the pipeline.
echo -e "${green}Generating the pipeline from the YAML template..."
echo -e ${white}
az pipelines create --name $name --yaml-path ".pipelines/azure-pipelines.yml"
