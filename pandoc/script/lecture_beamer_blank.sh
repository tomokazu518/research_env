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
sed -i  's/plots_figures\//plots\//g' $BASENAME-temp.md

# texの図などの強調を太字から空欄に変更
sed -i  's/\\textbf/\\phantom/g' plots/*.tex

# gnuplotのマスタースライド用描画コマンドを削除
sed -i  '/\#plot-master\#/{n;d;}' plots/*.plt

# tikzの赤字・青字や塗りを透明に
sed -i   \
            -e 's/\[red/\[transparent/g' \
            -e 's/text=red/text=white/g' \
            -e 's/\[blue/\[transparent/g' \
            -e 's/text=blue/text=white/g'  \
            -e 's/opacity=0.1/opacity=0/g' \
        plots/*.tex

# Pandocでマークダウンをtexに変換
pandoc \
--template=/home/rstudio/pandoc/templates/lecture_beamer.latex \
--pdf-engine=xelatex \
--filter pandoc-plot \
-f markdown-auto_identifiers \
-F pandoc-crossref \
-t beamer \
-o $BASENAME-blank.tex \
$BASENAME-temp.md

# texソースの強調を赤字に変更
sed -i 's/\\textbf/\\phantom/g' $BASENAME-blank.tex 

# texのコンパイル
latexmk \
  -e "$dvipdf=q/dvipdfmx %O -o %D %S/" \
  -pdfxe -shell-escape $BASENAME-blank.tex

# 一時ファイルのクリーンアップ
latexmk \
-c $BASENAME-blank.tex

rm $BASENAME-temp.md
rm $BASENAME-blank.nav
rm $BASENAME-blank.snm
rm $BASENAME-blank.vrb
rm -f *.gp
rm -rf plots
