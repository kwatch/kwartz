            <!-- calendar-month -->
            <table cellpadding="2" summary="calendar of <?php echo $month; ?>, <?php echo $year; ?>">
              <caption>
                <i><?php echo $month; ?></i>&nbsp;<i><?php echo $year; ?></i>
              </caption>
              <thead>
                <tr bgcolor="#CCCCCC">
                  <th><span class="holiday">S</span></th>
                  <th>M</th><th>T</th><th>W</th><th>T</th><th>F</th><th>S</th>
                </tr>
              </thead>
              <tbody>
<?php $day = "&nbsp"; ?>
<?php $wday = 1; ?>
<?php while ($wday < $first_weekday) { ?>
<?php   if ($wday == 1) { ?>
                <tr>
<?php   } ?>
                  <td><?php if ($wday == 1) { ?>
<span class="holiday"><?php echo $day; ?></span><?php } else { ?>
<?php echo $day; ?><?php } ?>
</td>
<?php   $wday += 1; ?>
<?php } ?>
<?php $day = 0; ?>
<?php $wday -= 1; ?>
<?php while ($day < $num_days) { ?>
<?php   $day += 1; ?>
<?php   $wday = $wday % 7 + 1; ?>
<?php   if ($wday == 1) { ?>
                <tr>
<?php   } ?>
                  <td><?php if ($wday == 1) { ?>
<span class="holiday"><?php echo $day; ?></span><?php } else { ?>
<?php echo $day; ?><?php } ?>
</td>
<?php   if ($wday == 7) { ?>
                </tr>
<?php   } ?>
<?php } ?>
<?php if ($wday != 7) { ?>
<?php   $day = "&nbsp;"; ?>
<?php   while ($wday != 6) { ?>
                  <td><?php if ($wday == 1) { ?>
<span class="holiday"><?php echo $day; ?></span><?php } else { ?>
<?php echo $day; ?><?php } ?>
</td>
<?php     $wday += 1; ?>
<?php   } ?>
                </tr>
<?php } ?>
              </tbody>
            </table>
            &nbsp;
            <!-- /calendar-month -->
