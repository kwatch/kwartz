.	.=title:	README
.	.?author:	Makoto Kuwata <kwa(at)kuwata-lab.com>
.	.?revision:	$Rev$
.	.?lastupdate:	$Date$
.	
.	
.	
.EN	.$ About Kwartz and Kwartz-ruby
.JA	●KwartzとKwartz-rubyについて
.	
.EN	  Kwartz is a template system which realized the concept
.EN	  'Separation of Presentation Data and Presentation Logic'.
.EN	  It has the following features:
.JA	  Kwartzとは、『プレゼンテーションデータとプレゼンテーションロジックの分離』と
.JA	  いう概念を実現したテンプレートシステムです。
.JA	  次のような特徴があります。
.	
.EN	   .* Separate presentation logics from presentation data
.EN	   .* Multi programing language (Ruby, PHP, and Java)
.EN	   .* Runs Very fast
.EN	   .* Auto-Sanitizing and Partially Sanitizing
.EN	   .* Doesn't break HTML design at all
.EN	   .* Can handle any text file
.JA	   .* プレゼンテーションデータからプレゼンテーションロジックを分離できます。
.JA	   .* 複数のプログラミング言語に対応します（Ruby, PHP, Java）。
.JA	   .* 高速に動作します。
.JA	   .* 自動サニタイズ機能があります。
.JA	   .* HTMLデザインをまったく崩しません。
.JA	   .* どんな種類のテキストファイルでも扱うことができます。
.	
.EN	  Kwartz-ruby is an implementation of Kwartz in Ruby.
.EN	  Kwartz-php and Kwartz-java are now being developed.
.JA	  Kwartz-rubyは、Rubyで作られたKwartzの実装です。
.JA	  Kwartz-phpとKwartz-javaも現在開発中です。
.	
.EN	  See the Users' Guide for details.
.JA	  詳しくはユーザーズガイドをご覧ください。
.	
.	
.	
.EN	.$ Installation
.JA	●インストール
.	
.EN	  The following shows how to install Kwartz-ruby.
.JA	  インストール手順は次のとおりです。
.	
.		.====================
.EN		### Unarchive the kwartz-ruby-*.tar.gz
.JA		### ファイルを解凍する
.		$ tar xjf kwartz-ruby-*.tar.gz
.		$ cd kwartz-ruby-*/
.		
.EN		### Run setup.rb
.JA		### setup.rbを実行する
.		$ ruby setup.rb config
.		$ ruby setup.rb setup
.		$ su -
.		# ruby setup.rb install
.		.====================
.	
.	
.	
.EN	.$ Announcement
.JA	●お知らせ
.	
.EN	  .* This project had subsidized by Exploratory Software Project of IPA
.EN	     (Information-Technology Promotion Agency Japan).
.EN	     See http://www.ipa.go.jp/about/english/index.html for IPA.
.JA	  .* 本プロジェクトは、情報処理推進機構(IPA)による平成15年度未踏ソフトウェア
.JA	     創造事業の支援を受けました。未踏ソフトウェア創造事業については
.JA	      http://www.ipa.go.jp/jinzai/esp/ をご覧ください。
.	
.EN	  .* If you have any questions or reports, send a e-mail to 
.EN	     <kwa(at)kuwata-lab.com> with a title starting with '[Kwartz-ruby]'.
.JA	  .* 質問やレポートは <kwa(at)kuwata-lab.com> までお知らせください。
.JA	     その際、タイトルに '[Kwartz-ruby]' と入れてください。
.	
.EN	  .* GPL is applied to Kwartz-ruby Software, but not applied to files
.EN	     which are genereated by Kwartz-ruby.
.JA	  .* ライセンスにはGPLを使用していますが、GPLが適用されるのはKwartz-ruby
.JA	     ソフトウェアに対してであり、Kwartz-rubyから生成されたファイルには
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
.	  .% bin/kwartz
.EN		Command file
.JA		コマンドファイル
.		
.	  .% bin/mkmethod-php
.EN		Utility script to generate PHP function from templates.
.JA		テンプレートからPHPの関数を生成するユーティリティ。
.		
.	  .% lib/kwartz.rb, lib/kwartz/*
.EN		Library files.
.JA		ライブラリファイル
.		
.	  .% ChangeLog
.EN		Change log
.JA		変更履歴
.		
.	  .% doc/users-guide.*.html
.EN		Users' Guide
.JA		ユーザーズガイド
.		
.	  .% doc/reference.*.html
.EN		Reference Manual
.JA		リファレンスマニュアル
.		
.	  .% examples/
.EN		Examples. You have to install Kwartz-ruby before trying
.EN		these examples.
.JA		サンプル。Kwartz-rubyをインストールしてから実行してください。
.		
.	  .% test/
.EN		UnitTest Programs
.JA		ユニットテストプログラム
.		
.	
.	
.EN	.$ License
.JA	●ライセンス
.	
.	  Copyright (C) 2004-2005 kuwata-lab
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
.	
.	
.EN	.$ Special Thanks
.JA	●Special Thanks
.	
.EN	.* Shu-yu Guo - He corrected my English of users' guide. Very Thanks!
.JA	.* Shu-yu Guo - ユーザーズガイドの英語を直してくれました。多謝。
.	
.#@EOF
