<html>
  <head>
    <title>Kwartz Benchmark</title>
  </head>
  <body>
    <h1>Kwartz Benchmark</h1>

    <table>
<#assign i = 0>
<#list list as item>
  <#assign i = i + 1>
  <#if i % 2 == 0 >
    <#assign color = "#FFCCCC">
  <#else>
    <#assign color = "#CCCCFF">
  </#if>
      <tr bgcolor="${color}">
        <td>${item}</td>
      </tr>
</#list>
    </table>

  </body>
</html>
