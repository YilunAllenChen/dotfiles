sudo apt install $(paste -sd " " ./requirements)
pip install -r ./pip_requirements
npm install -g -s $(paste -sd " " ./npm_requirements)

