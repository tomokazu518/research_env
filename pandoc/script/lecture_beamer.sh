FILENAME=$1
DIRNAME=$2

BASENAME=${FILENAME%.*}

cp $FILENAME $BASENAME-temp.md
rm $BASENAME.aux

if [ "$(uname)" = 'Darwin' ]; then
  alias sed=gsed
fi

mkdir plots
cp plots_figures/*.* plots/

# 図・グラフのフォルダ
sed -i 's/plots_figures\//plots\//g' $BASENAME-temp.md

# texの図などの強調を太字から赤字に変更
sed -i 's/\\textbf/\\textcolor{red}/g' plots/*.tex

# gnuplotの空欄スライド用描画コマンドを削除
sed -i '/\#plot-blank\#/{n;d;}' plots/*.plt










# Pandocでマークダウンをtexに変換
pandoc \
--template=/home/rstudio/pandoc/templates/lecture_beamer.latex \
--pdf-engine=xelatex \
--filter pandoc-plot \
-f markdown-auto_identifiers \
-F pandoc-crossref \
-t beamer \
-o $BASENAME.tex \
$BASENAME-temp.md

# texソースの強調を太字から赤字に変更
sed -i 's/\\textbf/\\textcolor{red}/g' $BASENAME.tex

# texのコンパイル
latexmk \
  -pdfxe -shell-escape $BASENAME.tex

# 一時ファイルのクリーンアップ
latexmk \
-c $BASENAME.tex

rm $BASENAME-temp.md
rm $BASENAME.nav
rm $BASENAME.snm
rm $BASENAME.vrb
rm -f *.gp
rm -rf plots
