.	.=title:	README
.	.?author:	Makoto Kuwata <kwa(at)kuwata-lab.com>
.	.?revision:	$Rev$
.	.?lastupdate:	$Date$
.	
.	
.	
.EN	.$ About KwartzPHP
.JA	●KwartzPHPについて
.	
.EN	  KwartzPHP is a template system which realized the concept
.EN	  'Separation of Presentation Data and Presentation Logic'.
.EN	  It has the following features:
.JA	  KwartzPHPとは、『プレゼンテーションデータとプレゼンテーション
.JA	  ロジックの分離』という概念を実現したテンプレートシステムです。
.JA	  次のような特徴があります。
.	
.EN	   .* Separate presentation logics from presentation data
.EN	   .* Runs Very fast
.EN	   .* Multi programing language (PHP, Ruby, Java)
.EN	   .* Auto-Sanitizing and Partially Sanitizing
.EN	   .* Doesn't break HTML design at all
.EN	   .* Can handle any text file
.JA	   .* プレゼンテーションデータからプレゼンテーションロジックを分離できます。
.JA	   .* 高速に動作します。
.JA	   .* 複数のプログラミング言語に対応します（Ruby, PHP, Java）。
.JA	   .* 自動サニタイズ機能があります。
.JA	   .* HTMLデザインをまったく崩しません。
.JA	   .* どんな種類のテキストファイルでも扱うことができます。
.	
.EN	  See the Users' Guide for details.
.JA	  詳しくはユーザーズガイドをご覧ください。
.	
.	
.	
.EN	.$ Installation
.JA	●インストール
.	
.EN	  KwartzPHP requires PHP 5.
.EN	  You have to install PHP 5 to use KwartzPHP.
.JA	  KwartzPHPは、PHP 5を必要とします。
.JA	  KwartzPHPを使う前にPHP 5をインストールしてください。
.	
.EN	  The following shows how to install KwartzPHP.
.JA	  インストール手順は次のとおりです。
.	
.EN	  .% Installation with PEAR Installer:
.JA	  .% PEARインストーラを使う場合
.EN		Just type 'pear install KwartzPHP*.tbz'.
.JA		'pear install KwartzPHP*.tbz' とタイプするだけです。
.EN		.====================
.EN		$ su -
.EN		# pear install KwartzPHP*.tgz
.EN		.====================
.	
.EN	  .% Manual Installation:
.JA	  .% 手動でインストールする場合
.EN		Copy library files and command script to proper directories.
.JA		ライブラリファイルとコマンドスクリプトを適切なディレクトリに
.JA		コピーしてください。
.		.====================
.EN		### Unarchive the KwartzPHP*.tgz
.JA		### ファイルを解凍する
.		$ tar xzf KwartzPHP*.tgz
.		$ cd KwartzPHP*/
.		
.EN		### copy library files
.JA		### ライブラリファイルをコピーする
.		$ cp -a Kwartz.php Kwartz /usr/local/lib/php
.		
.EN		### copy command script
.JA		### コマンドスクリプトをコピーする
.		$ cp -a kwartz-php /usr/local/bin
.		.====================
.	
.	
.	
.EN	.$ Announcement
.JA	●お知らせ
.	
.EN	  .* This project is subsidized by Exploratory Software Project of IPA
.EN	     (Information-Technology Promotion Agency Japan).
.EN	     See http://www.ipa.go.jp/about/english/index.html for IPA.
.JA	  .* 本プロジェクトは、情報処理推進機構(IPA)による平成15年度未踏ソフトウェア
.JA	     創造事業の支援を受けています。未踏ソフトウェア創造事業については
.JA	      http://www.ipa.go.jp/jinzai/esp/ をご覧ください。
.	
.EN	  .* If you have any questions or reports, send a e-mail to 
.EN	     <kwa(at)kuwata-lab.com> with a title starting with '[KwartzPHP]'.
.JA	  .* 質問やレポートは <kwa(at)kuwata-lab.com> までお知らせください。
.JA	     その際、タイトルに '[KwartzPHP]' と入れてください。
.	
.EN	  .* GPL is applied to KwartzPHP Software, but not applied to files
.EN	     which are genereated by KwartzPHP.
.JA	  .* ライセンスにはGPLを使用していますが、GPLが適用されるのはKwartzPHP
.JA	     ソフトウェアに対してであり、KwartzPHPから生成されたファイルには
.JA	     適用されません。
.	
.	
.	
.EN	.$ Manifest
.JA	●ファイルの説明
.	
.	  .% README.en.txt, README.ja.txt
.EN		Readme file (in English/Japanese).
.JA		Readmeファイル（英語、日本語）
.		
.	  .% kwartz-php
.EN		Command file
.JA		コマンドファイル
.		
.	  .% Kwartz.php, Kwartz/*.php
.EN		Library files.
.JA		ライブラリファイル
.		
.	  .% ChangeLog.en.html, ChangeLog.ja.html
.EN		Change log (in English/Japanese).
.JA		変更履歴（英語、日本語）
.		
.	  .% test/
.EN		UnitTest
.JA		UnitTest
.		
.	  .% doc/users-guide.*.html
.EN		Users' Guide
.JA		ユーザーズガイド
.		
.	  .% doc/reference.*.html
.EN		Reference Manual
.JA		リファレンスマニュアル
.		
.	
.	
.EN	.$ License
.JA	●ライセンス
.	
.	  Copyright (C) 2004 kuwata-lab
.	  All rights reserved.
.	  
.	  This software is under GNU GPL.
.	  
.	  This program is free software; you can redistribute it and/or modify
.	  it under the terms of the GNU General Public License as published by
.	  the Free Software Foundation; either version 2 of the License, or
.	  (at your option) any later version.
.	  
.	  This program is distributed in the hope that it will be useful,
.	  but WITHOUT ANY WARRANTY; without even the implied warranty of
.	  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
.	  GNU General Public License for more details..	
.	
.#@EOF
