#!/bin/bash

# Script untuk membuat 20 commit dan push ke repository baru
# Pastikan Anda berada di folder repository yang ingin di-push

# Variabel yang dapat disesuaikan
REPO_URL="git@github.com:DinarNp/next2.git"  # Ganti dengan URL repo Anda
BRANCH_NAME="main"                                    # Ganti dengan branch yang diinginkan
TOTAL_COMMITS=10                                      # Jumlah total commit yang ingin dibuat

# Variabel untuk backdate commit (Januari - Februari 2024)
START_DATE="2021-07-01"  # 1 Januari 2024
END_DATE="2021-08-29"    # 29 Februari 2024 (tahun kabisat)

# Fungsi untuk mengecek apakah git sudah terinstall
check_git() {
  if ! command -v git &> /dev/null; then
    echo "Error: Git tidak terinstall. Silakan install git terlebih dahulu."
    exit 1
  fi
}

# Fungsi untuk membuat git repository baru jika belum ada
init_repo() {
  if [ ! -d ".git" ]; then
    echo "Initializing repository baru..."
    git init
    git checkout -b "$BRANCH_NAME"
  else
    echo "Repository sudah ada."
    # Mengecek branch saat ini dan membuat branch baru jika perlu
    CURRENT_BRANCH=$(git branch --show-current)
    if [ "$CURRENT_BRANCH" != "$BRANCH_NAME" ]; then
      git checkout -b "$BRANCH_NAME" 2>/dev/null || git checkout "$BRANCH_NAME"
    fi
  fi
}

# Fungsi untuk menambahkan remote jika belum ada
add_remote() {
  if ! git remote | grep -q "origin"; then
    echo "Menambahkan remote origin..."
    git remote add origin "$REPO_URL"
  else
    echo "Remote origin sudah ada, mengupdate URL..."
    git remote set-url origin "$REPO_URL"
  fi
}

# Fungsi untuk mendistribusikan jumlah commit secara benar-benar acak dengan maksimal 5 per hari
distribute_commits() {
  local total=$1
  local days=60  # Jumlah hari dalam 2 bulan (Jan-Feb 2024)
  local day_commits=()
  local i
  
  # Inisialisasi array dengan nilai 0
  for ((i=1; i<=days; i++)); do
    day_commits[$i]=0
  done
  
  # Distribusikan commit secara acak dengan maksimal 5 per hari
  while [ $total -gt 0 ]; do
    # Pilih hari secara acak
    day=$((RANDOM % days + 1))
    
    # Tambahkan 1 commit ke hari tersebut jika belum melebihi maksimal 5
    if [ ${day_commits[$day]} -lt 5 ]; then
      day_commits[$day]=$((day_commits[$day] + 1))
      total=$((total - 1))
    fi
  done
  
  echo "${day_commits[@]}"
}

# Fungsi untuk menghasilkan tanggal untuk hari tertentu dalam periode Jan-Feb 2024
generate_date_for_day_index() {
  local day_index=$1
  local date
  local month
  local day
  local year=2025
  
  # Tentukan bulan dan tanggal
  if [ $day_index -le 31 ]; then
    # Januari (1-31)
    month=3
    day=$day_index
  else
    # Februari (1-29)
    month=4
    day=$((day_index - 31))
  fi
  
  # Format dengan leading zero
  if [ $day -lt 10 ]; then
    day="0$day"
  fi
  if [ $month -lt 10 ]; then
    month="0$month"
  fi
  
  # Tentukan jam, menit, dan detik secara acak
  local hour=$(( RANDOM % 24 ))
  local minute=$(( RANDOM % 60 ))
  local second=$(( RANDOM % 60 ))
  
  # Format dengan leading zero
  if [ $hour -lt 10 ]; then
    hour="0$hour"
  fi
  if [ $minute -lt 10 ]; then
    minute="0$minute"
  fi
  if [ $second -lt 10 ]; then
    second="0$second"
  fi
  
  # Nama hari dan bulan
  local day_names=("Sun" "Mon" "Tue" "Wed" "Thu" "Fri" "Sat")
  local month_names=("Jan" "Feb" "Mar" "Apr" "May" "Jun" "Jul" "Aug" "Sep" "Oct" "Nov" "Dec")
  local day_name=${day_names[$((RANDOM % 7))]}
  local month_name=${month_names[$((month-1))]}
  
  echo "$day_name $month_name $day $hour:$minute:$second $year +0700"
}

# Fungsi utama untuk membuat commits
make_commits() {
  echo "Mendistribusikan $TOTAL_COMMITS commits secara acak dalam periode Jan-Feb 2024..."
  
  # File placeholder untuk memastikan selalu ada sesuatu untuk di-commit
  PLACEHOLDER_FILE="commit_history.txt"
  touch $PLACEHOLDER_FILE
  echo "# Commit History" > $PLACEHOLDER_FILE
  
  # Daftar pesan commit untuk variasi
  COMMIT_MESSAGES=(
    "Initial setup"
    "Update configuration"
    "Add documentation"
    "Implement feature"
    "Fix bug in code"
    "Update styling"
    "Refactor code structure"
    "Add new tests"
    "Improve performance"
    "Add new assets"
    "Update dependencies"
    "Fix typo in docs"
    "Improve error handling"
    "Update README"
    "Add new component"
    "Fix responsive issues"
    "Update API endpoints"
    "Optimize database queries"
    "Implement security fix"
    "Add analytics tracking"
  )
  
  # Distribusikan commit ke hari-hari (benar-benar acak, maksimal 5 per hari)
  DAY_COMMITS=($(distribute_commits $TOTAL_COMMITS))
  
  # Loop untuk setiap hari dalam periode
  COMMIT_COUNT=1
  local days_with_commits=0
  for day_index in {1..60}; do
    # Jumlah commit untuk hari ini
    COMMITS_TODAY=${DAY_COMMITS[$day_index]}
    
    # Hanya lanjutkan jika ada commit hari ini
    if [ $COMMITS_TODAY -gt 0 ]; then
      days_with_commits=$((days_with_commits + 1))
      
      # Generate tanggal berdasarkan indeks hari
      CURRENT_DATE=$(generate_date_for_day_index $day_index)
      
      echo "Hari ke-$day_index ($CURRENT_DATE): $COMMITS_TODAY commits"
      
      # Buat commit untuk hari ini
      for ((j=1; j<=COMMITS_TODAY; j++)); do
        # Pilih pesan commit secara acak
        MESSAGE_INDEX=$((RANDOM % ${#COMMIT_MESSAGES[@]}))
        COMMIT_MSG="[${COMMIT_COUNT}%] ${COMMIT_MESSAGES[$MESSAGE_INDEX]}"
        
        # Update file placeholder untuk memastikan ada perubahan
        echo "Commit #$COMMIT_COUNT (Hari $day_index, #$j): $COMMIT_MSG" >> $PLACEHOLDER_FILE
        
        # Add semua perubahan
        git add .
        
        # Set environment variables untuk backdating
        export GIT_AUTHOR_DATE="$CURRENT_DATE"
        export GIT_COMMITTER_DATE="$CURRENT_DATE"
        
        # Buat commit dengan tanggal yang sudah diset
        git commit -m "$COMMIT_MSG" --date="$GIT_AUTHOR_DATE"
        
        echo "Commit $COMMIT_COUNT/$TOTAL_COMMITS: $COMMIT_MSG (Tanggal: $CURRENT_DATE)"
        COMMIT_COUNT=$((COMMIT_COUNT + 1))
      done
    fi
  done
  
  echo "Total hari dengan commit: $days_with_commits dari 60 hari ($(( (days_with_commits * 100) / 60 ))%)"
}

# Fungsi untuk melakukan push
do_push() {
  echo "Melakukan push ke repository remote..."
  git push -u origin "$BRANCH_NAME" --force
  
  if [ $? -eq 0 ]; then
    echo "Push berhasil! Repository telah dipush ke $REPO_URL dengan $TOTAL_COMMITS commits."
    
    # Verifikasi jumlah commit
    local commit_count=$(git rev-list --count HEAD)
    echo "Verifikasi: Repository sekarang memiliki $commit_count commit."
  else
    echo "Error: Terjadi kesalahan saat melakukan push."
    echo "Pastikan URL repository benar dan Anda memiliki akses untuk push."
  fi
}

# Main execution flow
echo "=== GIT REPOSITORY 20 COMMITS PUSHER ==="
echo "Script ini akan membuat $TOTAL_COMMITS commits dan push ke repository."
echo "Repository target: $REPO_URL"
echo "Branch: $BRANCH_NAME"
echo "Range tanggal commit: $START_DATE hingga $END_DATE (acak, maks 5 per hari)"
echo ""
echo "PERINGATAN: Script ini akan mengubah repository Git Anda."
read -p "Lanjutkan? (y/n): " CONFIRM

if [ "$CONFIRM" != "y" ] && [ "$CONFIRM" != "Y" ]; then
  echo "Dibatalkan."
  exit 0
fi

check_git
init_repo
add_remote
make_commits
do_push

echo "Selesai!"