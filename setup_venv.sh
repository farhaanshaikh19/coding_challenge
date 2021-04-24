#!/bin/zsh

echo "RUNNING SCRIPT: $0"

# pyenv must be installed for this script to work
pyenv_root=$(pyenv root)
echo "pyenv_root: $pyenv_root"
if [[ -z $pyenv_root ]]; then
  echo "ERROR: pyenv must be installed"
  exit 3
fi

# get repo directory path from script absolute path
project_dir="$( cd "$(dirname "$0")" || exit ; pwd -P )"
echo "project_dir: $project_dir"

requirements_filepath="$project_dir/requirements.txt"
python_version_filepath="$project_dir/.python-version"

# checks to insure required files exist
if [[ ! -f $requirements_filepath || ! -f $python_version_filepath ]]; then
  echo "ERROR: Either requirements.txt or .python-version not present in $project_dir."
  exit 5
fi

# read in python version
python_version=$( head -n 1 "$python_version_filepath" )
echo "Python Version: $python_version"

python_exe_path="$pyenv_root/versions/$python_version/bin/python"

echo "python_version: $python_version"
echo "python_exe_path: $python_exe_path"

# check that the python version has been installed in pyenv (an executable exists)
if [[ ! -x $python_exe_path ]]; then
  echo "$python_version needs to be installed in pyenv; Installing..."
  pyenv install "$python_version"
fi

new_venv_name="venv"
new_venv_path="$project_dir/$new_venv_name"
echo "new_venv_path: $new_venv_path"

if [[ -d $new_venv_path ]]; then
  echo "ERROR: $new_venv_path already exists, exiting setup script" ;
  exit 7 ;
fi

# create new virtual environment
$python_exe_path -m venv "$new_venv_path" || {
  echo "ERROR: venv creation failed, exiting setup script" ;
  exit 10 ;
}

# activate the virtual environment
# shellcheck source=path/to/venv/bin/activate
source "$new_venv_path/bin/activate" || {
  echo "venv activation failed, exiting setup script" ;
  exit 11 ;
}

# install project requirements
pip install --upgrade pip
pip install -r "$requirements_filepath" || {
  echo "requirement installation failed exiting setup script" ;
  deactivate ;
  exit 12 ;
}

site_packages_location="$(python -c "from distutils.sysconfig import get_python_lib; print(get_python_lib())")"
echo "site_packages_location: $site_packages_location"
if [[ ! -d $site_packages_location ]]
  then
    echo "ERROR: Invalid site_packages_location - ($site_packages_location)"
    deactivate;
    exit 30
fi

# add project dir to venv "PYTHONPATH"
echo "$project_dir" > "$site_packages_location/project-paths.pth"

# deactivate venv
deactivate

echo "Python venv setup completed: $new_venv_path"
