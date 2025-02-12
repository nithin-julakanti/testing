airflow_dag_dir="C:/Users/nithinsharma.julakan/Downloads/pushgit"
github_repo_url="https://github.com/nithin-julakanti/testing.git"
github_repo_name="testing"
read -p "Enter the date (YYYY/MM/DD): " input_date
today=$(date -d "$input_date" '+%b %d')

if [ ! -d "$airflow_dag_dir" ]; then
  echo "Directory does not exist."
  exit 1
fi

cd "$airflow_dag_dir"
if [ ! -d .git ]; then
  git init
  git remote add origin "$github_repo_url"
  git checkout -b dev
else
  git checkout dev
  echo "Already Intialized local Repo."
fi

cd "$github_repo_name"
git pull origin dev

branches=$(git branch -r )
for branch in $branches; do
  if [ "$branch" == "dev" ]; then
    git checkout dev
  else
    git checkout -b dev
  fi
done

new_dags=$(ls -l "$airflow_dag_dir" | grep "$today" | grep '\.py$' | awk '{print $9}')
if [ -z "$new_dags" ]; then
  echo "No new DAGs are found on $today."
  exit 1
else
  echo "List of new DAGs added on $today:"
  echo "$new_dags"
  for dag in $new_dags; do
    cp "$airflow_dag_dir/$dag" . /dev/null 2>&1
    git add "$dag"
  done
  git commit -m "On $today, new DAGs have been committed."
  git push origin dev
  echo "Pushed $(echo $new_dags) DAGs on $today to the GitHub repository"
fi