<!-- XSLT-Stylesheet von http://kitwallace.posterous.com/svg-graphs-via-xslt-on-exist auf Basis von http://graph2svg.googlecode.com -->
<xsl:stylesheet xmlns:m="http://graph2svg.googlecode.com" xmlns:gr="http://graph2svg.googlecode.com" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:math="http://exslt.org/math" extension-element-prefixes="math" exclude-result-prefixes="m math xs gr" version="2.0">
    <xsl:output method="xml" encoding="utf-8" indent="yes"/>
    <!--doctype-public="-//W3C//DTD SVG 1.1//EN"
"doctype-system="http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd"-->
    <xsl:variable name="pi" select="3.14159265359"/>
    <xsl:template match="gr:osgr">
        <xsl:call-template name="m:osgr2svg">
            <xsl:with-param name="graph" select="."/>
        </xsl:call-template>
    </xsl:template>
    <xsl:template name="m:osgr2svg">
        <xsl:param name="graph"/>
        <xsl:variable name="gra">
            <ph>
                <xsl:apply-templates select="$graph/@*" mode="m:processValues"/>
                <xsl:attribute name="legend" select="    if (($graph/@legend) = 'right') then 'right' else    if (($graph/@legend) = 'left') then 'left' else    if (($graph/@legend) = 'top') then 'top' else    if (($graph/@legend) = 'bottom') then 'bottom' else 'none' "/>
                <xsl:apply-templates select="$graph/(*|text())" mode="m:processValues">
                    <xsl:with-param name="graph" select="$graph" tunnel="yes"/>
                </xsl:apply-templates>
            </ph>
        </xsl:variable>
        <!--xsl:copy-of select="$gra/ph"/-->

        <!-- constants -->
        <xsl:variable name="titleMargin" select="10"/>
        <xsl:variable name="titleFontSize" select="18"/>
        <xsl:variable name="labelFontSize" select="10"/>
        <xsl:variable name="labelFontWd" select="0.68"/>
        <!-- average length of letter divided a font high -->
        <xsl:variable name="labelAngle" select="25"/>
        <xsl:variable name="graphMargin" select="15"/>
        <xsl:variable name="yAxisMarkDist" select="25"/>
        <xsl:variable name="yAxisMarkAutoCount" select="11"/>
        <!-- automatic choice will try to be close to this values -->
        <xsl:variable name="axesAutoCoef" select="0.8"/>
        <!-- coeficient used for decision wheather display 0 whe automatically choosing axes range -->
        <xsl:variable name="axesStroke-width" select="1"/>
        <xsl:variable name="legendMargin" select="15"/>
        <xsl:variable name="legendPictureWd" select="28"/>
        <xsl:variable name="legendPictureHg" select="20"/>
        <!-- height of the pictogram in the legend, have to be less then legendLineHg-->
        <xsl:variable name="legendGap" select="5"/>
        <xsl:variable name="legendFontSize" select="12"/>
        <xsl:variable name="legendFontWd" select="0.61"/>
        <xsl:variable name="legendLineHg" select="24"/>
        <!-- high of a row in legend -->
        <xsl:variable name="labelInFontSize" select="10"/>
        <xsl:variable name="labelOutFontSize" select="10"/>
        <xsl:variable name="labelOutFontWd" select="0.60"/>
        <xsl:variable name="majorMarkLen" select="3"/>
        <!-- 1/2 of the length of major marks on axes -->
        <xsl:variable name="majorMarkStroke-width" select="1"/>
        <xsl:variable name="minorMarkLen" select="2"/>
        <!-- 1/2 of the length of minor marks on axes-->
        <xsl:variable name="minorMarkStroke-width" select="0.5"/>
        <xsl:variable name="majorGridStroke-width" select="0.4"/>
        <xsl:variable name="majorGridColor" select=" '#222' "/>
        <xsl:variable name="minorGridStroke-width" select="0.2"/>
        <xsl:variable name="minorGridColor" select=" '#111' "/>
        <xsl:variable name="pieRadiusX" select="100"/>
        <xsl:variable name="pieRadiusY" select="if ($gra/ph/@effect = '3D') then 60 else 100"/>
        <xsl:variable name="pie3DHg" select="if ($gra/ph/@effect = '3D') then 10 else 0"/>
        <xsl:variable name="labelInRadiusRatio" select="0.75"/>


        <!-- color schemas definitions -->
        <xsl:variable name="colorSchemeColor" select="('#14f', '#ff1', '#f0d', '#3f1', '#f33', '#1ff', '#bbb', '#13b', '#909', '#a81', '#090', '#b01', '#555')"/>
        <xsl:variable name="colorSchemeCold" select="('#07bbbb', '#09a317', '#19009f', '#9a0084', '#6efaff', '#88f917', '#a9a7f6', '#fbbbf3', '#002dff', '#ff00bf')"/>
        <xsl:variable name="colorSchemeWarm" select="('#d82914', '#f2ee15', '#21ab03', '#c5a712', '#a4005a', '#f17a2e', '#c9f581', '#ffbcc5', '#ffffc4', '#f8887f')"/>
        <xsl:variable name="colorSchemeGrey" select="('#ccc', '#888', '#444', '#eee', '#aaa', '#666', '#222')"/>
        <xsl:variable name="colorSchemeBlack" select="('black')"/>

        <!-- variable calculations-->
        <!-- 2D / 3D -->
        <xsl:variable name="depthX" select="if ($gra/ph/@effect = '3D') then 8 else 0"/>
        <xsl:variable name="depthY" select="if ($gra/ph/@effect = '3D') then 8 else 0"/>

        <!-- calculation of common variables -->
        <!-- color schemas -->
        <xsl:variable name="colorSch" select="    if ($gra/ph/@colorScheme = 'black') then $colorSchemeBlack else    if ($gra/ph/@colorScheme = 'cold') then $colorSchemeCold else    if ($gra/ph/@colorScheme = 'warm') then $colorSchemeWarm else    if ($gra/ph/@colorScheme = 'grey') then $colorSchemeGrey else  $colorSchemeColor "/>
        <!-- title and the legend -->
        <xsl:variable name="titleHg" select="if ($gra/ph/title) then 2*$titleMargin + $titleFontSize else 0"/>
        <xsl:variable name="legendWd" select="    if ($gra/ph/@legend = 'left' or $gra/ph/@legend =  'right') then (     $legendMargin + $legendPictureWd + $legendGap  +     $legendFontSize * $legendFontWd *      max(for $a in ($gra/ph/names/name, '') return string-length($a))    ) else     if ($gra/ph/@legend = 'top' or $gra/ph/@legend =  'bottom') then (     2*$legendMargin + sum(      for $a in ($gra/ph/names/name) return        string-length($a)*$legendFontSize*$legendFontWd +$legendPictureWd +$legendGap +$legendMargin)     ) else 0       "/>
        <xsl:variable name="legendHg" select="    if ($gra/ph/@legend = 'left' or $gra/ph/@legend =  'right') then (     2*$legendMargin +$legendLineHg *      count($gra/ph/names/name)    ) else     if ($gra/ph/@legend = 'top' or $gra/ph/@legend =  'bottom') then (     $legendMargin + $legendLineHg    ) else 0"/>
        <xsl:variable name="legendL" select="if ($gra/ph/@legend = 'left') then $legendWd else 0"/>
        <xsl:variable name="legendR" select="if ($gra/ph/@legend = 'right') then $legendWd else 0"/>
        <xsl:variable name="legendT" select="if ($gra/ph/@legend = 'top') then $legendHg else 0"/>
        <xsl:variable name="legendB" select="if ($gra/ph/@legend = 'bottom') then $legendHg else 0"/>


        <!-- division according GRAPHTYPE-->
        <xsl:choose>
            <xsl:when test="$gra/ph/@graphType = 'pie'">
                <!-- ***************graphType = 'pie'-->
                <!-- calculation of variables for pie-->
                <!-- pie graph itselvse -->
                <xsl:variable name="pieValSum" select="sum($gra/ph/values/value)"/>
                <xsl:variable name="pieTSpace" select="$graphMargin +     (if ($gra/ph/@labelOut = 'none') then 0 else 1.5*$labelOutFontSize)"/>
                <xsl:variable name="pieBSpace" select="$graphMargin + $pie3DHg +    (if ($gra/ph/@labelOut = 'none') then 0 else 1.5*$labelOutFontSize)"/>
                <xsl:variable name="pieLSpace" select="$graphMargin +     (if (not ($gra/ph/@labelOut = 'none'))  then      max((0, (      for $a in $gra/ph/values/value return (       string-length(        if ($gra/ph/@labelOut = 'value')  then $a else         if ($gra/ph/@labelOut = 'percent') then format-number(. div $pieValSum, '#%') else        if ($gra/ph/@labelOut = 'name') then          $gra/ph/names/name[count($a/preceding-sibling::value)+1] else '')       )*$labelOutFontSize*$labelOutFontWd       - $pieRadiusX - ($pieRadiusX+0.85*$labelOutFontSize)*        math:sin(2*$pi*(sum($a/preceding-sibling::value) + 0.5*$a) div $pieValSum) )     ))    else 0)   "/>
                <xsl:variable name="pieRSpace" select="$graphMargin+     (if (not ($gra/ph/@labelOut = 'none'))  then      max((0, (      for $a in $gra/ph/values/value return (       string-length(        if ($gra/ph/@labelOut = 'value')  then $a else         if ($gra/ph/@labelOut = 'percent') then format-number(. div $pieValSum, '#%') else        if ($gra/ph/@labelOut = 'name') then          $gra/ph/names/name[count($a/preceding-sibling::value)+1] else '')       )*$labelOutFontSize*$labelOutFontWd       - $pieRadiusX + ($pieRadiusX+0.85*$labelOutFontSize)*        math:sin(2*$pi*(sum($a/preceding-sibling::value) + 0.5*$a) div $pieValSum) )     ))    else 0)"/>
                <xsl:variable name="graphWd" select="$pieLSpace + 2*$pieRadiusX + $pieRSpace"/>
                <xsl:variable name="graphHg" select="$pieTSpace + 2*$pieRadiusY + $pieBSpace"/>
                <xsl:variable name="pieXCenter" select="$legendL +  $pieLSpace + $pieRadiusX +    (if ($gra/ph/@legend = 'top' or $gra/ph/@legend =  'bottom') then      max(($legendWd - $graphWd, 0)) div 2     else 0)"/>
                <xsl:variable name="pieYCenter" select="$titleHg + $legendT + $pieTSpace + $pieRadiusY +    (if ($gra/ph/@legend = 'left' or $gra/ph/@legend =  'right') then      max(($legendHg - $graphHg, 0)) div 2     else 0)"/>

                <!-- ledend items layout for pie type -->
                <xsl:variable name="legendSX" select="     if ($gra/ph/@legend = 'right' or $gra/ph/@legend = 'left') then (     for $a in $gra/ph/names/name return      (if ($gra/ph/@legend = 'right') then $graphWd else $legendMargin)    ) else    if ($gra/ph/@legend = 'top' or $gra/ph/@legend = 'bottom') then (     for $a in $gra/ph/names/name return (      $legendMargin + 0.5*max(($graphWd - $legendWd, 0)) +      sum( for $b in $a/preceding-sibling::name return          (string-length($b)*$legendFontSize*$legendFontWd          +$legendPictureWd +$legendGap +$legendMargin)         )     )    ) else ''    "/>
                <xsl:variable name="legendSY" select="     if ($gra/ph/@legend = 'right' or $gra/ph/@legend = 'left') then (     for $a in $gra/ph/names/name return      $titleHg + 0.5*max(($graphHg - $legendHg, 0)) + $legendMargin +      $legendLineHg * (count($a/preceding-sibling::name) + 0.5)    ) else     if ($gra/ph/@legend = 'top' or $gra/ph/@legend = 'bottom') then (     for $a in $gra/ph/names/name return (      $titleHg + (if ($gra/ph/@legend = 'bottom') then $graphHg else $legendMargin) +0.5*$legendLineHg     )    ) else ''    "/>
                <!-- whole window for pie -->
                <xsl:variable name="width" select="$legendL + $legendR +     (if ($gra/ph/@legend = 'top' or $gra/ph/@legend =  'bottom') then max(($graphWd, $legendWd)) else $graphWd)"/>
                <xsl:variable name="height" select="$titleHg +  $legendT + $legendB +     (if ($gra/ph/@legend = 'left' or $gra/ph/@legend =  'right') then max(($graphHg, $legendHg)) else $graphHg)"/>

                <!-- begin of the SVG document for pie type-->
                <svg class="pie" viewBox="0 0 {$width} {$height}">
                    <desc>
                        <xsl:value-of select="$gra/ph/title"/>
                    </desc>

                    <!-- type a title for pie -->
                    <g>
                        <xsl:if test="count($gra/ph/title) &gt; 0">
                            <text x="{$width div 2}" y="{$titleMargin + $titleFontSize}" text-anchor="middle" font-family="Verdana" font-size="{$titleFontSize}" fill="{if ($gra/ph/title/@color) then $gra/ph/title/@color else 'black'}">
                                <xsl:value-of select="$gra/ph/title"/>
                            </text>
                        </xsl:if>
                    </g>

                    <!-- the pie graph -->
                    <g stroke-width="1" stroke="black" stroke-linejoin="round">
                        <xsl:for-each select="$gra/ph/values/value">
                            <xsl:variable name="sn" select="count(preceding-sibling::value)"/>
                            <xsl:variable name="cn" select="$sn mod count($colorSch)+1"/>
                            <xsl:variable name="cc" select="if (./@color) then ./@color else $colorSch[$cn]"/>
                            <xsl:variable name="startS" select="sum(preceding-sibling::value)"/>
                            <xsl:variable name="endS" select="$startS+ (.)"/>
                            <xsl:variable name="sA" select="2*$pi*$startS div $pieValSum"/>
                            <xsl:variable name="eA" select="2*$pi*$endS div $pieValSum"/>
                            <xsl:variable name="laf" select="if (2*(.) &gt; $pieValSum) then 1 else 0"/>
                            <path d="{concat('M', $pieXCenter, ',', $pieYCenter,      ' l', $pieRadiusX*math:sin($sA), ',',  -$pieRadiusY*math:cos($sA),      ' a', $pieRadiusX, ',', $pieRadiusY, ' 0 ', $laf, ',1 ',       $pieRadiusX*(math:sin($eA) - math:sin($sA)), ',',      -$pieRadiusY*(math:cos($eA)  - math:cos($sA)), ' z')}" fill="{$cc}"/>
                            <xsl:if test="($gra/ph/@effect = '3D') and      (($sA &gt; 0.5*$pi and $sA &lt; 1.5*$pi ) or      ($eA &gt; 0.5*$pi and $eA &lt; 1.5*$pi ))">
                                <xsl:variable name="sAp" select="if ($sA &lt; 0.5*$pi) then 0.5*$pi else $sA"/>
                                <xsl:variable name="eAp" select="if ($eA &gt; 1.5*$pi) then 1.5*$pi else $eA"/>
                                <path d="{concat('M', $pieXCenter +$pieRadiusX*math:sin($sAp), ',',         $pieYCenter -$pieRadiusY*math:cos($sAp),       ' v', $pie3DHg,       ' a', $pieRadiusX, ',', $pieRadiusY, ' 0 ', $laf, ',1 ',       $pieRadiusX*(math:sin($eAp) - math:sin($sAp)), ',',      -$pieRadiusY*(math:cos($eAp)  - math:cos($sAp)),       ' v', -$pie3DHg,       ' a', $pieRadiusX, ',', $pieRadiusY, ' 0 ', $laf, ',0 ',       -$pieRadiusX*(math:sin($eAp) - math:sin($sAp)), ',',      $pieRadiusY*(math:cos($eAp)  - math:cos($sAp)), ' z')}" fill="{$cc}"/>
                            </xsl:if>
                            <!-- areas in legend -->
                            <xsl:if test="not ($gra/ph/@legend = 'none') and ($legendSY[1+$sn] &gt; 0)">
                                <rect x="{$legendSX[1+$sn]}" y="{$legendSY[1+$sn] - 0.5*$legendPictureHg}" width="{$legendPictureWd}" height="{$legendPictureHg}" fill="{$cc}"/>
                            </xsl:if>
                        </xsl:for-each>
                    </g>
                    <xsl:if test="$gra/ph/@effect = '3D'">
                        <defs>
                            <linearGradient id="lg_pie" x1="{$pieXCenter -$pieRadiusX}" y1="0" x2="{$pieXCenter +$pieRadiusX}" y2="0" gradientUnits="userSpaceOnUse">
                                <stop offset="0" stop-opacity="0.6"/>
                                <stop offset="0.35" stop-opacity="0"/>
                                <stop offset="0.5" stop-opacity="0"/>
                                <stop offset="1" stop-opacity="0.8"/>
                            </linearGradient>
                        </defs>
                        <path d="{concat('M', $pieXCenter +$pieRadiusX, ',', $pieYCenter,       ' v', $pie3DHg,       ' a', $pieRadiusX, ',', $pieRadiusY, ' 0 1,1 ', -2*$pieRadiusX, ',0',      ' v', -$pie3DHg,       ' a', $pieRadiusX, ',', $pieRadiusY, ' 0 1,0 ', 2*$pieRadiusX, ',0', ' z')}" fill="url(#lg_pie)" stroke="none"/>
                    </xsl:if>

                    <!-- values in labelIn - pie-->
                    <xsl:if test="(not ($gra/ph/@labelIn = 'none'))">
                        <g text-anchor="middle" font-family="Verdana" font-size="{$labelInFontSize}" fill="black">
                            <xsl:for-each select="$gra/ph/values/value">
                                <xsl:variable name="sn" select="count(preceding-sibling::value)"/>
                                <xsl:variable name="middleS" select="sum(preceding-sibling::value) + 0.5*(.)"/>
                                <xsl:variable name="mA" select="2*$pi*$middleS div $pieValSum"/>
                                <text x="{$pieXCenter + $pieRadiusX*$labelInRadiusRatio*math:sin($mA)}" y="{$pieYCenter -$pieRadiusY*$labelInRadiusRatio*math:cos($mA) + 0.35* $labelInFontSize}">
                                    <xsl:choose>
                                        <xsl:when test="$gra/ph/@labelIn = 'value' ">
                                            <xsl:value-of select="."/>
                                        </xsl:when>
                                        <xsl:when test="$gra/ph/@labelIn = 'percent' ">
                                            <xsl:value-of select="format-number(. div $pieValSum, '#%')"/>
                                        </xsl:when>
                                        <xsl:when test="$gra/ph/@labelIn = 'name' ">
                                            <xsl:value-of select="$gra/ph/names/name[1+$sn]"/>
                                        </xsl:when>
                                        <xsl:otherwise/>
                                    </xsl:choose>
                                </text>
                            </xsl:for-each>
                        </g>
                    </xsl:if>

                    <!-- values in labelOut - pie-->
                    <xsl:if test="(not ($gra/ph/@labelOut = 'none'))">
                        <g font-family="Verdana" font-size="{$labelOutFontSize}" fill="black">
                            <xsl:for-each select="$gra/ph/values/value">
                                <xsl:variable name="sn" select="count(preceding-sibling::value)"/>
                                <xsl:variable name="middleS" select="sum(preceding-sibling::value) + 0.5*(.)"/>
                                <xsl:variable name="mA" select="2*$pi*$middleS div $pieValSum"/>
                                <text x="{$pieXCenter + ($pieRadiusX+0.85*$labelOutFontSize)*math:sin($mA)}" y="{$pieYCenter -($pieRadiusY + 0.85*$labelOutFontSize +        ( if (math:cos($mA) &lt; 0)  then $pie3DHg else 0 )      )*math:cos($mA) + 0.35* $labelOutFontSize}" text-anchor="{if ($mA &lt;= $pi) then 'start' else 'end'}">
                                    <xsl:choose>
                                        <xsl:when test="$gra/ph/@labelOut = 'value' ">
                                            <xsl:value-of select="."/>
                                        </xsl:when>
                                        <xsl:when test="$gra/ph/@labelOut = 'percent' ">
                                            <xsl:value-of select="format-number(. div $pieValSum, '#%')"/>
                                        </xsl:when>
                                        <xsl:when test="$gra/ph/@labelOut = 'name' ">
                                            <xsl:value-of select="$gra/ph/names/name[1+$sn]"/>
                                        </xsl:when>
                                        <xsl:otherwise/>
                                    </xsl:choose>
                                </text>
                            </xsl:for-each>
                        </g>
                    </xsl:if>

                    <!-- legend for pie-->
                    <xsl:if test="(not ($gra/ph/@legend = 'none'))">
                        <g text-anchor="start" font-family="Verdana" font-size="{$legendFontSize}" fill="black">
                            <xsl:for-each select="$gra/ph/names/name">
                                <xsl:variable name="sn" select="count(preceding-sibling::name)"/>
                                <!--xsl:variable name="cn"  select="$sn mod count($colorSch)+1"/>
			<xsl:variable name="cc"  select="if (@color) then @color else $colorSch[$cn]"/-->
                                <text x="{$legendSX[1+$sn] + $legendPictureWd + $legendGap}" y="{$legendSY[1+$sn] + 0.35* $legendFontSize}">
                                    <xsl:value-of select="."/>
                                </text>
                            </xsl:for-each>
                        </g>
                    </xsl:if>

                    <!-- frame aroung pie chart -->
                    <rect x="0.5" y="0.5" width="{$width - 1}" height="{$height - 1}" stroke="black" fill="none" stroke-width="1"/>
                </svg>
            </xsl:when>
            <xsl:otherwise>
                <!--******************************graphType = 'norm' a other types-->
                <!-- variable calculation for norm type -->
                <!-- X axis - categories -->
                <xsl:variable name="catGap" select="10"/>
                <xsl:variable name="colWd" select="30"/>
                <xsl:variable name="catCount" as="xs:integer" select="count($gra/ph/names/name) cast as xs:integer"/>
                <xsl:variable name="catWd" select="2*$catGap+$colWd"/>
                <xsl:variable name="xAxisWd" select="$catCount * $catWd"/>
                <xsl:variable name="maxXLabelWd" select="0.9 * $labelFontSize * $labelFontWd *    max(for $a in $gra/ph/names/name return string-length($a))"/>
                <xsl:variable name="xLabelRotation" select="if ($maxXLabelWd &gt;= $catWd) then $maxXLabelWd else 0"/>

                <!-- Y axis -->
                <xsl:variable name="dataMaxY" select="max($gra/ph/values/value)"/>
                <xsl:variable name="dataMinY" select="min($gra/ph/values/value)"/>
                <xsl:variable name="dataYDif" select="$dataMaxY - $dataMinY"/>
                <xsl:variable name="viewMaxY" select="    if ($gra/ph/@yAxisType = 'shifted') then $dataMaxY else     (if ($gra/ph/@yAxisType = 'withZero') then max(($dataMaxY, 0)) else     (if ((- $dataYDif * $axesAutoCoef &lt; $dataMaxY) and ($dataMaxY &lt; 0)) then 0 else $dataMaxY))"/>
                <xsl:variable name="viewMinY" select="    if ($gra/ph/@yAxisType = 'shifted') then $dataMinY else     (if ($gra/ph/@yAxisType = 'withZero') then max(($dataMinY, 0)) else     (if ((0 &lt; $dataMinY) and  ($dataMinY &lt; $dataYDif * $axesAutoCoef)) then 0 else $dataMinY))"/>
                <xsl:variable name="yAxisStep" select="if ($gra/ph/@yAxisType='log') then 1 else    m:Step(if ($viewMaxY != $viewMinY) then ($viewMaxY - $viewMinY) else 0.00001, $yAxisMarkAutoCount)"/>
                <xsl:variable name="yAxisMax" select="if ($gra/ph/@stacked='percentage') then 1 else m:GMax($viewMaxY, $yAxisStep)"/>
                <xsl:variable name="yAxisMin" select="- m:GMax(- $viewMinY, $yAxisStep)"/>
                <xsl:variable name="yAxisLen" select="$yAxisMax - $yAxisMin"/>
                <xsl:variable name="yAxisMarkCount" select="round($yAxisLen div $yAxisStep) cast as xs:integer"/>
                <xsl:variable name="yAxisHg" select="$yAxisMarkCount * $yAxisMarkDist"/>
                <xsl:variable name="yKoef" select="- $yAxisHg div $yAxisLen"/>
                <xsl:variable name="originYShift" select="    if ($gra/ph/@xAxisPos = 'bottom') then 0 else    if ($yAxisMin &gt;= 0) then 0 else - min((- $yAxisMin, $yAxisLen)) * $yKoef "/>
                <xsl:variable name="maxYLabelWd" select="$labelFontSize * $labelFontWd *    max(for $a in (0 to $yAxisMarkCount) return      string-length(      if ($gra/ph/@stacked='percentage') then        concat(m:Round(($yAxisMin + $a * $yAxisStep) * 100, $yAxisStep), '% ')       else       string(m:Round($yAxisMin + $a * $yAxisStep, $yAxisStep))      )     + (if ($gra/ph/@yAxisType='log') then 2 else 0)      )"/>

                <!-- norm graph itselves -->
                <xsl:variable name="yAxisTSpace" select="$graphMargin + max(($labelFontSize div 2, $depthY))"/>
                <xsl:variable name="yAxisBSpace" select="$graphMargin +     max(($labelFontSize div 2, max(($labelFontSize + $majorMarkLen,      m:R($xLabelRotation*math:sin($pi*$labelAngle div 180)) )) - $originYShift))"/>
                <xsl:variable name="xAxisLSpace" select="$graphMargin + $maxYLabelWd "/>
                <xsl:variable name="xAxisRSpace" select="$graphMargin +     max((m:R($xLabelRotation*math:cos($pi*$labelAngle div 180)) -$catWd +$catGap, $depthX))"/>
                <xsl:variable name="graphWd" select="$xAxisLSpace + $xAxisWd + $xAxisRSpace"/>
                <xsl:variable name="graphHg" select="$yAxisTSpace + $yAxisHg + $yAxisBSpace"/>
                <xsl:variable name="xAxisLStart" select="$legendL + $xAxisLSpace +     (if ($gra/ph/@legend = 'top' or $gra/ph/@legend =  'bottom') then      max(($legendWd - $graphWd, 0)) div 2     else 0)"/>
                <xsl:variable name="yAxisTStart" select="$titleHg + $legendT + $yAxisTSpace +     (if ($gra/ph/@legend = 'left' or $gra/ph/@legend =  'right') then      max(($legendHg - $graphHg, 0)) div 2     else 0)"/>
                <xsl:variable name="originX" select="$xAxisLStart"/>
                <xsl:variable name="originY" select="$yAxisTStart + $yAxisHg - $originYShift"/>
                <xsl:variable name="yShift" select="$yAxisTStart + $yAxisHg - $yKoef * $yAxisMin"/>

                <!-- legend itmes layout for norm type -->
                <xsl:variable name="legendSX" select="     if ($gra/ph/@legend = 'right' or $gra/ph/@legend = 'left') then (     for $a in $gra/ph/names/name return      (if ($gra/ph/@legend = 'right') then $graphWd else $legendMargin)    ) else    if ($gra/ph/@legend = 'top' or $gra/ph/@legend = 'bottom') then (     for $a in $gra/ph/names/name return (      $legendMargin + 0.5*max(($graphWd - $legendWd, 0)) +      sum( for $b in $a/preceding-sibling::name return          (string-length($b)*$legendFontSize*$legendFontWd          +$legendPictureWd +$legendGap +$legendMargin)         )     )    ) else ''    "/>
                <xsl:variable name="legendSY" select="     if ($gra/ph/@legend = 'right' or $gra/ph/@legend = 'left') then (     for $a in $gra/ph/names/name return      $titleHg + 0.5*max(($graphHg - $legendHg, 0)) + $legendMargin +      $legendLineHg * (count($a/preceding-sibling::name) + 0.5)    ) else     if ($gra/ph/@legend = 'top' or $gra/ph/@legend = 'bottom') then (     for $a in $gra/ph/names/name return (      $titleHg + (if ($gra/ph/@legend = 'bottom') then $graphHg else $legendMargin) +0.5*$legendLineHg     )    ) else ''    "/>
                <!-- whole window for norm type -->
                <xsl:variable name="width" select="$legendL + $legendR +     (if ($gra/ph/@legend = 'top' or $gra/ph/@legend =  'bottom') then max(($graphWd, $legendWd)) else $graphWd)"/>
                <xsl:variable name="height" select="$titleHg +  $legendT + $legendB +     (if ($gra/ph/@legend = 'left' or $gra/ph/@legend =  'right') then max(($graphHg, $legendHg)) else $graphHg)"/>

                <!-- variables for axis and grids - norm type-->
                <xsl:variable name="LB" select="$gra/ph/@xAxisPos = 'bottom'"/>
                <xsl:variable name="logDiv" select="0.301, 0.176, 0.125, 0.097, 0.079, 0.067, 0.058, 0.051, 0.046"/>
                <!-- log10(i) - log10(i-1)   for  i=2,3,..,10 -->
                <xsl:variable name="mYpom" select="        if ($LB) then      (0 to $yAxisMarkCount)    else      if ($yAxisMin &gt; 0) then (1 to $yAxisMarkCount) else     if ($yAxisMax &lt; 0) then (0 to $yAxisMarkCount - 1) else       (0 to $yAxisMarkCount)   "/>
                <xsl:variable name="yAxisDiv" select="    if ($gra/ph/@yAxisDivision = 'none') then -1 else    if ($gra/ph/@yAxisDivision = '1') then 1 else    if ($gra/ph/@yAxisDivision = '2') then 2 else    if ($gra/ph/@yAxisDivision = '4') then 4 else    if ($gra/ph/@yAxisDivision = '5') then 5 else    if ($gra/ph/@yAxisDivision = '10') then 10 else 1    "/>

                <!-- start of SVG document -->
                <svg class="bar" viewBox="0 0 {$width} {$height}">
                    <desc>
                        <xsl:value-of select="$gra/ph/title"/>
                    </desc>

                    <!-- type a title for the norm graph -->
                    <g>
                        <xsl:if test="count($gra/ph/title) &gt; 0">
                            <text x="{$width div 2}" y="{$titleMargin + $titleFontSize}" text-anchor="middle" font-family="Verdana" font-size="{$titleFontSize}" fill="{if ($gra/ph/title/@color) then $gra/ph/title/@color else 'black'}">
                                <xsl:value-of select="$gra/ph/title"/>
                            </text>
                        </xsl:if>
                    </g>


                    <!-- major and minor grid for both axes -->
                    <xsl:if test="($gra/ph/@xGrid='minor' or $gra/ph/@xGrid='both')">
                        <!-- minor grid of X axis -->
                        <xsl:variable name="gXMinor" select="      concat('M', m:R($xAxisLStart +$catGap +0.5*$colWd  +$depthX), ',', $yAxisTStart -$depthY),     for $a in (1 to $catCount) return       concat(' v', $yAxisHg, ' m', 2*$catGap+$colWd, ',', -$yAxisHg) ,     if ($gra/ph/@effect = '3D') then (      concat('M', $xAxisLStart +$catGap + 0.5*$colWd, ',', $originY),      for $a in (1 to $catCount) return        concat('l', $depthX, ',', -$depthY, ' m', 2*$catGap+$colWd -$depthX, ',', $depthY)     ) else ' '     "/>
                        <path d="{$gXMinor}" stroke="{$minorGridColor}" stroke-width="{$minorGridStroke-width}" fill="none"/>
                    </xsl:if>
                    <xsl:if test="($gra/ph/@xGrid !='none' and $gra/ph/@xGrid !='minor' )">
                        <!-- major grid of X axis -->
                        <xsl:variable name="gXMajor1" select="     concat('M', $xAxisLStart +$depthX, ',', $yAxisTStart -$depthY, ' l0,', $yAxisHg),     for $a in (1 to $catCount) return (      concat('m', $catWd, ',-', $yAxisHg, ' l0,', $yAxisHg)     ),     if ($gra/ph/@effect = '3D') then (      concat('M', $xAxisLStart, ',', $originY, ' l', $depthX, ',', -$depthY),      for $a in (1 to $catCount) return       concat('m', $catWd -$depthX, ',', $depthX, ' l', $depthX, ',', -$depthY)     ) else ''     "/>
                        <path d="{$gXMajor1}" stroke="{$majorGridColor}" stroke-width="{$majorGridStroke-width}" fill="none"/>
                    </xsl:if>
                    <xsl:if test="$gra/ph/@yGrid = 'minor' or $gra/ph/@yGrid = 'both' ">
                        <!-- minor grid of Y axis -->
                        <xsl:variable name="gYMinor" select="    concat('M', $xAxisLStart, ',', $yAxisTStart+$yAxisHg - $mYpom[1]*$yAxisMarkDist),    (if ($gra/ph/@effect = '3D') then concat('l', $depthX, ',', -$depthY) else ''),    concat(' l', $xAxisWd, ',0 '),    if ($gra/ph/@yAxisType='log') then (     for $a in $mYpom[. != 1], $b in $logDiv return (      if ($gra/ph/@effect = '3D') then       concat('m', -$xAxisWd -$depthX, ',', $depthY -$yAxisMarkDist * $b,         'l', $depthX, ',', -$depthY, ' l', $xAxisWd, ',0 ')      else       concat('m-', $xAxisWd, ',-', $yAxisMarkDist * $b, ' l', $xAxisWd, ',0 ')     )    ) else (     for  $a in $mYpom[. != 1], $b in (1 to $yAxisDiv) return (      if ($gra/ph/@effect = '3D') then       concat('m', -$xAxisWd -$depthX, ',', $depthY -$yAxisMarkDist div $yAxisDiv,         'l', $depthX, ',', -$depthY, ' l', $xAxisWd, ',0 ')      else       concat('m-', $xAxisWd, ',-', $yAxisMarkDist div $yAxisDiv, ' l', $xAxisWd, ',0 ')     )    ) "/>
                        <path d="{$gYMinor}" stroke="{$minorGridColor}" stroke-width="{$minorGridStroke-width}" fill="none"/>
                    </xsl:if>
                    <xsl:if test="($gra/ph/@yGrid = 'major' or $gra/ph/@yGrid = 'minor')     and ($yAxisDiv &gt; 0) ">
                        <!-- major grid of Y axis -->
                        <xsl:variable name="gYMajor" select="     concat('M', $xAxisLStart, ',', $yAxisTStart + $yAxisHg - $mYpom[1] * $yAxisMarkDist),     (if ($gra/ph/@effect = '3D') then concat('l', $depthX, ',', -$depthY) else ''),     concat(' l', $xAxisWd, ',0 '),     for $n in $mYpom[. != 1] return (      if ($gra/ph/@effect = '3D') then       concat('m', -$xAxisWd -$depthX, ',', $depthY -$yAxisMarkDist,         'l', $depthX, ',', -$depthY, ' l', $xAxisWd, ',0 ')      else       concat('m-', $xAxisWd, ',-', $yAxisMarkDist, ' l', $xAxisWd, ',0 ')     ) "/>
                        <path d="{$gYMajor}" stroke="{$majorGridColor}" stroke-width="{$majorGridStroke-width}" fill="none"/>
                    </xsl:if>

                    <!-- drawing of columns -->
                    <xsl:if test="not ($gra/ph/@colType = 'none')">
                        <!-- gradient definition for area filling -->
                        <xsl:if test="($gra/ph/@colType = 'cone') or ($gra/ph/@colType = 'cylinder') ">
                            <xsl:variable name="gradLBorder" select="-0.7"/>
                            <xsl:variable name="gradRBorder" select="0.9"/>
                            <defs>
                                <xsl:for-each select="$gra/ph/values/value">
                                    <xsl:variable name="vn" select="count(preceding-sibling::value)"/>
                                    <xsl:variable name="cn" select="$vn mod count($colorSch)+1"/>
                                    <xsl:variable name="cc" select="if (./@color) then (./@color) else $colorSch[$cn]"/>
                                    <xsl:variable name="pomS" select="if ($gra/ph/@effect = '3D') then -0.5*$depthX else 0"/>
                                    <linearGradient id="lg{$vn}" x1="{$gradLBorder*$colWd -$pomS}" y1="0" x2="{$gradRBorder*$colWd -$pomS}" y2="0" gradientUnits="userSpaceOnUse">
                                        <stop offset="0" stop-color="#000"/>
                                        <stop offset="0.35" stop-color="{$cc}"/>
                                        <stop offset="1" stop-color="#000"/>
                                    </linearGradient>
                                </xsl:for-each>
                            </defs>
                        </xsl:if>

                        <!-- drawing of columns itselves -->
                        <g stroke-width="0.4" stroke="black" stroke-linejoin="round">
                            <xsl:for-each select="$gra/ph/values/value">
                                <xsl:variable name="vn" select="count(preceding-sibling::value)"/>
                                <xsl:variable name="cn" select="$vn mod count($colorSch)+1"/>
                                <xsl:variable name="cc" select="if (@color) then (@color) else $colorSch[$cn]"/>
                                <xsl:variable name="x" select="$xAxisLStart + $catGap + 0.5*$colWd + $vn*$catWd "/>
                                <xsl:variable name="y" select="$originY"/>
                                <g transform="translate({m:R($x)}, {$y})" fill="{      if ($gra/ph/@colType = 'cone' or $gra/ph/@colType = 'cylinder') then       concat('url(#lg', $vn, ')') else $cc}">
                                    <xsl:call-template name="m:drawCol">
                                        <!-- dwaw a column -->
                                        <xsl:with-param name="type" select="$gra/ph/@colType"/>
                                        <xsl:with-param name="effect" select="$gra/ph/@effect"/>
                                        <xsl:with-param name="color" select="$cc"/>
                                        <xsl:with-param name="hg" select="$originY - $yShift - $yKoef * (.)"/>
                                        <xsl:with-param name="tW" select="0"/>
                                        <xsl:with-param name="bW" select="1"/>
                                        <xsl:with-param name="dpX" select="$depthX"/>
                                        <xsl:with-param name="dpY" select="$depthY"/>
                                        <xsl:with-param name="colW" select="0.5*$colWd"/>
                                    </xsl:call-template>
                                </g>
                                <!-- column of a given type for the legend  -->
                                <xsl:if test="not ($gra/ph/@legend = 'none')">
                                    <g transform="translate({$legendSX[1+$vn] + 0.5*$legendPictureWd},         {$legendSY[1+$vn] +0.5*$legendPictureHg})" fill="{if ($gra/ph/@colType = 'cone' or $gra/ph/@colType = 'cylinder') then        concat('url(#lg', $vn, ')') else $cc}">
                                        <xsl:call-template name="m:drawCol">
                                            <!-- draw a column-->
                                            <xsl:with-param name="type" select="$gra/ph/@colType"/>
                                            <xsl:with-param name="effect" select="$gra/ph/@effect"/>
                                            <xsl:with-param name="color" select="$cc"/>
                                            <xsl:with-param name="hg" select="$legendPictureHg -$depthX*0.5"/>
                                            <xsl:with-param name="tW" select="0"/>
                                            <xsl:with-param name="bW" select="1"/>
                                            <xsl:with-param name="dpX" select="$depthX*0.5"/>
                                            <xsl:with-param name="dpY" select="$depthY*0.5"/>
                                            <xsl:with-param name="colW" select="0.5*0.5*$colWd"/>
                                        </xsl:call-template>
                                    </g>
                                </xsl:if>
                            </xsl:for-each>
                        </g>
                    </xsl:if>

                    <!-- major and minor marks for both axes -->
                    <g stroke="black">
                        <xsl:if test="(not ($gra/ph/@xAxisDivision='none' or $gra/ph/@xAxisDivision='major'))">
                            <!-- minor marks of X axis -->
                            <xsl:variable name="mXMinor" select="      concat('M', $xAxisLStart +$catGap + $colWd div 2, ',', $originY -$minorMarkLen),     for $a in (1 to $catCount) return       concat(' v', $minorMarkLen, ' m', 2*$catGap+$colWd, ',-', $minorMarkLen)"/>
                            <path d="{$mXMinor}" stroke-width="{$minorMarkStroke-width}"/>
                        </xsl:if>
                        <xsl:if test="($gra/ph/@xAxisDivision='major' or $gra/ph/@xAxisDivision='both' )">
                            <!-- major marks of X axis -->
                            <xsl:variable name="mXMajor" select="      concat('M', $xAxisLStart, ',', $originY, ' v', $majorMarkLen),     for $n in (2 to $catCount) return concat('m', $catWd, ',-', $majorMarkLen, ' v', $majorMarkLen)"/>
                            <path d="{$mXMajor}" stroke-width="{$majorMarkStroke-width}"/>
                        </xsl:if>
                        <xsl:if test="($yAxisDiv &gt; 1)">
                            <!-- minor marks for Y axis -->
                            <xsl:variable name="mYMinor" select="    concat('M', m:R($originX -$minorMarkLen), ',', m:R($yAxisTStart +$yAxisHg -$mYpom[1]*$yAxisMarkDist),       ' l', m:R(2*$minorMarkLen), ',0 '),     if ($gra/ph/@yAxisType='log') then (     for $a in $mYpom[. != 1], $b in $logDiv return       concat('m-', m:R(2*$minorMarkLen), ',-', m:R($yAxisMarkDist*$b), ' l', m:R(2*$minorMarkLen), ',0 ')    ) else (     for $n in (for $a in (1 to $yAxisDiv) return $mYpom[. != 1]) return       concat('m-', m:R(2*$minorMarkLen), ',-', m:R($yAxisMarkDist div $yAxisDiv), ' l', m:R(2*$minorMarkLen), ',0 ')    )"/>
                            <path d="{$mYMinor}" stroke-width="{$minorMarkStroke-width}"/>
                        </xsl:if>
                        <xsl:if test="($yAxisDiv &gt; 0)">
                            <!-- major marks for Y axis -->
                            <xsl:variable name="mYMajor" select="      concat('M', m:R($originX - $majorMarkLen), ',', m:R($yAxisTStart + $yAxisHg - $mYpom[1] * $yAxisMarkDist),      ' l', m:R(2 * $majorMarkLen), ',0 '),     for $n in $mYpom[(.) != 1] return       concat('m-', m:R(2 * $majorMarkLen), ',-', m:R($yAxisMarkDist), ' l', m:R(2 * $majorMarkLen), ',0 ')   "/>
                            <path d="{$mYMajor}" stroke-width="{$majorMarkStroke-width}"/>
                        </xsl:if>
                    </g>

                    <!-- X axis with labels -->
                    <line x1="{$xAxisLStart}" y1="{$originY}" x2="{$xAxisLStart + $xAxisWd}" y2="{$originY}" stroke="black" stroke-width="{$axesStroke-width}"/>
                    <!-- X axis labels -->
                    <xsl:if test="not ($xLabelRotation)">
                        <g text-anchor="middle" font-family="Verdana" font-size="{$labelFontSize}" fill="black">
                            <xsl:for-each select="$gra/ph/names/name">
                                <xsl:variable name="nn" select="count(preceding-sibling::name)"/>
                                <text x="{$xAxisLStart + ($nn +0.5)*$catWd}" y="{$originY + $majorMarkLen + $labelFontSize}">
                                    <xsl:value-of select="."/>
                                </text>
                            </xsl:for-each>
                        </g>
                    </xsl:if>
                    <xsl:if test="$xLabelRotation">
                        <g font-family="Verdana" font-size="{$labelFontSize}" fill="black">
                            <xsl:for-each select="$gra/ph/names/name">
                                <xsl:variable name="nn" select="count(preceding-sibling::name)"/>
                                <g transform="translate({m:R($xAxisLStart + ($nn)*$catWd +$catGap)},       {m:R($originY + $majorMarkLen + $labelFontSize)}) rotate({$labelAngle}) ">
                                    <text>
                                        <xsl:value-of select="."/>
                                    </text>
                                </g>
                            </xsl:for-each>
                        </g>
                    </xsl:if>


                    <!-- Y axis with labels -->
                    <g stroke="black" stroke-width="{$axesStroke-width}">
                        <xsl:if test="$mYpom[1] != 0">
                            <line stroke-dasharray="2,3" x1="{$originX}" y1="{$yAxisTStart + $yAxisHg - $yAxisMarkDist}" x2="{$originX}" y2="{$yAxisTStart + $yAxisHg}"/>
                        </xsl:if>
                        <line x1="{$originX}" y1="{$yAxisTStart + $yAxisHg - $mYpom[1] * $yAxisMarkDist}" x2="{$originX}" y2="{$yAxisTStart + $yAxisHg - $mYpom[last()]*$yAxisMarkDist}"/>
                        <xsl:if test="$mYpom[last()] != $yAxisMarkCount">
                            <line stroke-dasharray="2,3" x1="{$originX}" y1="{$yAxisTStart}" x2="{$originX}" y2="{$yAxisTStart + $yAxisMarkDist}"/>
                        </xsl:if>
                    </g>
                    <!-- Y axis labels -->
                    <xsl:if test="($yAxisDiv &gt; 0)">
                        <g text-anchor="end" font-family="Verdana" font-size="{$labelFontSize}" fill="black">
                            <xsl:for-each select="(for $a in ($mYpom[. &gt; -1]) return $yAxisMin + $a * $yAxisStep)">
                                <text x="{m:R($originX - $majorMarkLen - 3)}" y="{m:R($yShift + $yKoef * (.) + 0.35 * $labelFontSize)}">
                                    <xsl:value-of select="      if ($gra/ph/@stacked='percentage') then concat(m:Round(. * 100, $yAxisStep), '%') else       if ($gra/ph/@yAxisType='log') then 10 else m:Round(., $yAxisStep)"/>
                                    <xsl:if test="$gra/ph/@yAxisType='log'">
                                        <tspan font-size="{0.75*$labelFontSize}" dy="{-0.4*$labelFontSize}">
                                            <xsl:value-of select="."/>
                                        </tspan>
                                    </xsl:if>
                                </text>
                                <!--xsl:value-of select="(., $yAxisStep, m:Round(., 0.5))"/-->
                            </xsl:for-each>
                        </g>
                    </xsl:if>
                    <xsl:variable name="pX" select="$xAxisLStart +$catGap +0.5*$colWd"/>
                    <xsl:variable name="normValSum" select="sum($gra/ph/values/value)"/>
                    <!-- drawing of the curve -->
                    <xsl:if test="$gra/ph/@lineType != 'none'">
                        <xsl:variable name="lp" select="min(($catCount, count($gra/ph/values/value)))"/>
                        <xsl:variable name="sk" select="0.18"/>
                        <xsl:variable name="line" select="    concat('M', $pX, ',', m:R($yShift + $yKoef * $gra/ph/values/value[1])),     if ($gra/ph/@smooth = 'yes') then (     (for $a in (1 to $lp -2)  return       concat(' S ', m:R($pX +$a*$catWd - 2*$catWd*$sk),      ',', m:R($yShift + $yKoef *($gra/ph/values/value[$a+1] - ($gra/ph/values/value[$a+2] -         $gra/ph/values/value[$a])*$sk)),      ' ',  $pX +$a*$catWd,',', m:R($yShift + $yKoef *$gra/ph/values/value[$a+1]) )     ),     concat (' S ', $pX +($lp -1)*$catWd,',', m:R($yShift + $yKoef *$gra/ph/values/value[$lp])),     concat ($pX +($lp -1)*$catWd,',', m:R($yShift + $yKoef *$gra/ph/values/value[$lp]))    ) else (     for $a in (1 to $lp -1)  return       concat('L', $pX +$a*$catWd,',', m:R($yShift + $yKoef *$gra/ph/values/value[$a+1]))    )"/>
                        <path d="{$line}" stroke="black" stroke-width="1.5" fill="none" stroke-linecap="round" stroke-linejoin="round">
                            <xsl:if test="$gra/ph/@lineType != 'solid'">
                                <xsl:attribute name="stroke-dasharray" select="m:LineType($gra/ph/@lineType)"/>
                            </xsl:if>
                        </path>
                    </xsl:if>

                    <!-- draw points -->
                    <xsl:if test="some $a in ($gra/ph/values/value/@pointType, $gra/ph/@pointType)      satisfies $a != 'none'">
                        <g stroke-width="1.5" fill="none" stroke-linecap="round">
                            <xsl:for-each select="$gra/ph/values/value[(position() &lt;= $catCount) and     ((@pointType != 'none') or ($gra/ph/@pointType != 'none'))]">
                                <xsl:variable name="vn" select="count(preceding-sibling::value)"/>
                                <xsl:variable name="cn" select="$vn mod count($colorSch)+1"/>
                                <xsl:variable name="cc" select="if (@color) then (@color) else $colorSch[$cn]"/>
                                <xsl:call-template name="m:drawPoint">
                                    <!-- draw a point (mark) of a given type -->
                                    <xsl:with-param name="type" select="       if (@pointType) then @pointType else        if ($gra/ph/@pointType) then $gra/ph/@pointType else 'none'"/>
                                    <xsl:with-param name="x" select="$pX + $vn*$catWd "/>
                                    <xsl:with-param name="y" select="m:R($yShift + $yKoef * (.) )"/>
                                    <xsl:with-param name="color" select="$cc"/>
                                </xsl:call-template>
                                <!-- point of a given type for the legend -->
                                <xsl:if test="not ($gra/ph/@legend = 'none')">
                                    <xsl:call-template name="m:drawPoint">
                                        <xsl:with-param name="type" select="        if (@pointType) then @pointType else        if ($gra/ph/@pointType) then $gra/ph/@pointType else 'none'"/>
                                        <xsl:with-param name="x" select="$legendSX[1+$vn] + 0.5*$legendPictureWd"/>
                                        <xsl:with-param name="y" select="$legendSY[1+$vn]"/>
                                        <xsl:with-param name="color" select="$cc"/>
                                    </xsl:call-template>
                                </xsl:if>
                            </xsl:for-each>
                        </g>
                    </xsl:if>

                    <!-- values in labelIn - norm-->
                    <xsl:if test="(not ($gra/ph/@labelIn = 'none'))">
                        <g text-anchor="middle" font-family="Verdana" font-size="{$labelInFontSize}" fill="black">
                            <xsl:for-each select="$gra/ph/values/value">
                                <xsl:variable name="vn" select="count(preceding-sibling::value)"/>
                                <text x="{$pX + $vn*$catWd}" y="{m:R( 0.5*($originY +$yShift +$yKoef * (.)) + 0.35*$labelInFontSize )}">
                                    <xsl:choose>
                                        <xsl:when test="$gra/ph/@labelIn = 'value' ">
                                            <xsl:value-of select="."/>
                                        </xsl:when>
                                        <xsl:when test="$gra/ph/@labelIn = 'percent' ">
                                            <xsl:value-of select="format-number(. div $normValSum, '#%')"/>
                                        </xsl:when>
                                        <xsl:when test="$gra/ph/@labelIn = 'name' ">
                                            <xsl:value-of select="$gra/ph/names/name[1+$vn]"/>
                                        </xsl:when>
                                        <xsl:otherwise/>
                                    </xsl:choose>
                                </text>
                            </xsl:for-each>
                        </g>
                    </xsl:if>

                    <!-- values in labelOut - norm-->
                    <xsl:if test="(not ($gra/ph/@labelOut = 'none'))">
                        <g text-anchor="middle" font-family="Verdana" font-size="{$labelOutFontSize}" fill="black">
                            <xsl:for-each select="$gra/ph/values/value">
                                <xsl:variable name="vn" select="count(preceding-sibling::value)"/>
                                <text x="{$pX + $vn*$catWd  +0.5*$depthX}" y="{m:R($yShift + $yKoef * (.) ) +        (if (. &gt;= 0) then (-4 -$depthY) else ($labelOutFontSize +2))}">
                                    <xsl:choose>
                                        <xsl:when test="$gra/ph/@labelOut = 'value' ">
                                            <xsl:value-of select="."/>
                                        </xsl:when>
                                        <xsl:when test="$gra/ph/@labelOut = 'percent' ">
                                            <xsl:value-of select="format-number(. div $normValSum, '#%')"/>
                                        </xsl:when>
                                        <xsl:when test="$gra/ph/@labelOut = 'name' ">
                                            <xsl:value-of select="$gra/ph/names/name[1+$vn]"/>
                                        </xsl:when>
                                        <xsl:otherwise/>
                                    </xsl:choose>
                                </text>
                            </xsl:for-each>
                        </g>
                    </xsl:if>

                    <!-- legend norm -->
                    <xsl:if test="(not ($gra/ph/@legend = 'none'))">
                        <g text-anchor="start" font-family="Verdana" font-size="{$legendFontSize}" fill="black">
                            <xsl:for-each select="$gra/ph/names/name">
                                <xsl:variable name="sn" select="count(preceding-sibling::name)"/>
                                <!--xsl:variable name="cn"  select="$sn mod count($colorSch)+1"/>
			<xsl:variable name="cc"  select="if (@color) then @color else $colorSch[$cn]"/-->
                                <text x="{$legendSX[1+$sn] + $legendPictureWd + $legendGap}" y="{$legendSY[1+$sn] + 0.35* $legendFontSize}">
                                    <xsl:value-of select="."/>
                                </text>
                            </xsl:for-each>
                        </g>
                    </xsl:if>

                    <!-- frame around the whole graph - norm-->
                    <rect x="0.5" y="0.5" width="{$width - 1}" height="{$height - 1}" stroke="black" fill="none" stroke-width="1"/>
                    <!-- debuging frames >
	<rect x="1" y="1" width="{$width - 2}" height="{$titleHg - 2}"  
			stroke="blue" fill="none" stroke-width="1"/> 
	<rect x="{$legendL + 1}" y="{$titleHg + $legendT +1}" width="{$graphWd - 2}" height="{$graphHg - 2}"  
			stroke="red" fill="none" stroke-width="1"/> 
	<rect x="{$legendX - $legendMargin + 1}" y="{$legendY - $legendMargin + 1}" width="{$legendWd - 2}" height="{$legendHg - 2}"  
			stroke="blue" fill="none" stroke-width="1"/> 
	<rect x="0.5" y="{$titleMargin}" width="{$width - 0.5}" height="{$titleFontSize}"  
			stroke="grey" fill="none" stroke-width="1"/> 
	<xsl:if test="(not ($gra/ph/@legend = 'none'))">
		<xsl:for-each select="$gra/ph/values[title]">
			<xsl:variable name="sn"  select="count(preceding-sibling::values)"/>
			<rect x="{$legendSX[$sn+1]}" y="{$legendSY[$sn+1] -0.5*$legendLineHg}" width="{$legendPictureWd}" height="{$legendLineHg}"
					stroke="red" fill="none" stroke-width="1"/> 
		</xsl:for-each> 		
	</xsl:if>
	<  ^ kontrolni ramecky v legende -->

                    <!-- debuging prints -->
                    <text x="{$originX}" y="{$originY + 22}" font-family="Verdana" font-size="{$labelFontSize}">
                        <!--xsl:value-of select="$xLabelRotation"/><xsl:text> || </xsl:text>
		<xsl:value-of select="math:sin($labelAngle div 180) * $pi"/><xsl:text> || </xsl:text-->
                        <!--xsl:value-of select="if ($gra/ph/@pok != 'val') then 'true' else 'false' "/><xsl:text> || </xsl:text>
		<xsl:value-of select="if (not ($gra/ph/@pok = 'val')) then 'true' else 'false' "/><xsl:text> || </xsl:text>
		<xsl:copy-of select="(format-number(0.0000000001, '0.#######'))"/><xsl:text> || </xsl:text>
		<xsl:copy-of select="(format-number(0.00000001,    '0.#####'))"/><xsl:text> || </xsl:text>
		<xsl:copy-of select="(0.7000000000000001, 1, m:Round(0.7000000000000001, 1))"/><xsl:text> || </xsl:text>
		<xsl:copy-of select="(0.7000000000000001, 8, m:Round(0.7000000000000001, 8))"/><xsl:text> || </xsl:text-->
                    </text>
                    <text x="{$originX}" y="{$originY - 15}" font-family="Verdana" font-size="{$labelFontSize}"/>
                    <!--text x="{$legendX}" y="{$legendY}" font-family="Verdana" font-size="{$labelFontSize}">
		<xsl:value-of select="m:Round(3999.99, 20)"/>
	</text-->
                </svg>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!--******************************************************************************-->
    <!--************************************ end of the main template ************************-->
    <!--******************************************************************************-->
    <xsl:template match="gr:value" mode="m:processValues">
        <xsl:param name="graph" tunnel="yes"/>
        <value>
            <xsl:apply-templates select="@*|*" mode="m:processValues"/>
            <xsl:value-of select="   if ($graph/@yAxisType='log') then      m:Log10(if ((.) != 0) then math:abs(.) else 1) else (.)"/>
        </value>
    </xsl:template>
    <xsl:template match="gr:*" mode="m:processValues">
        <!-- copy gr element -->
        <xsl:element name="{local-name(.)}">
            <xsl:apply-templates select="@*|*|text()" mode="m:processValues"/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="*|text()|@*" mode="m:processValues">
        <!-- copies attributes, text and other elements -->
        <xsl:copy-of select="."/>
    </xsl:template>
    <xsl:function name="m:LineType">
        <!-- return "dasharay" for given curve (line) type -->
        <xsl:param name="t"/>
        <xsl:value-of select="   if ($t='dot') then '0.2,3' else    if ($t='dash') then '8,3' else    if ($t='longDash') then '14,3' else    if ($t='dash-dot') then '6,3,0.2,3' else    if ($t='longDash-dot') then '14,3,0.2,3' else    if ($t='dash-dot-dot') then '6,3,0.2,3,0.2,3' else    if ($t='dash-dash-dot-dot') then '6,3,6,3,0.2,3,0.2,3' else    if ($t='longDash-dash') then '14,3,6,3' else '0,16'"/>
    </xsl:function>
    <xsl:template name="m:drawCol">
        <!-- draw a column -->
        <xsl:param name="type"/>
        <xsl:param name="effect"/>
        <xsl:param name="color"/>
        <xsl:param name="hg"/>
        <xsl:param name="tW"/>
        <xsl:param name="bW"/>
        <xsl:param name="dpX"/>
        <xsl:param name="dpY"/>
        <xsl:param name="colW"/>
        <xsl:choose>
            <xsl:when test="$effect = '3D'">
                <!--3D-->
                <xsl:choose>
                    <xsl:when test="$type = 'cylinder' ">
                        <!--3D cylinder-->
                        <path d="M{-$colW +0.5*$dpX},{-$hg*(1-$bW) -0.5*$dpY} {m:Arc($colW,0.5*$dpX,0)}        v{-$hg*($bW -$tW)} {m:Arc(-$colW,0.5*$dpX,1)} z"/>
                        <path d="M{-$colW +0.5*$dpX},{-$hg*(1-$tW) -0.5*$dpY} {m:Arc($colW,0.5*$dpX,0)}        {m:Arc(-$colW,0.5*$dpX,0)}" fill="{$color}"/>
                    </xsl:when>
                    <xsl:when test="$type = 'cone' ">
                        <!--3D cone, TODO: not exact-->
                        <path d="M{-$colW*$bW +0.5*$dpX},{-$hg*(1-$bW) -0.5*$dpY}        {m:Arc($colW*$bW,0.5*$dpX*$bW,0)}        l{-$colW*($bW -$tW)},{-$hg*($bW -$tW)}        {m:Arc(-$colW*$tW,0.5*$dpX*$tW,1)} z"/>
                        <path d="M{-$colW*$tW +0.5*$dpX},{-$hg*(1-$tW) -0.5*$dpY}        {m:Arc($colW*$tW,0.5*$dpX*$tW,0)}        {m:Arc(-$colW*$tW,0.5*$dpX*$tW,0)} " fill="{$color}"/>
                    </xsl:when>
                    <xsl:when test="$type = 'pyramid' ">
                        <!--3D pyramid, TODO: to draw tW=0 separately -->
                        <path d="M{-$colW*$bW +0.5*$dpX*(1-$bW)},{-$hg*(1-$bW) -0.5*$dpY*(1-$bW)}       h{2*$colW*$bW}        l{-$colW*($bW -$tW) +0.5*$dpX*($bW -$tW)},{-$hg*($bW -$tW) -0.5*$dpY*($bW -$tW)}       h{-2*$colW*$tW} z"/>
                        <path d="M{$colW*$bW +0.5*$dpX*(1-$bW)},{-$hg*(1-$bW) -0.5*$dpY*(1-$bW)}       l{$dpX*$bW},{-$dpY*$bW}       l{-$colW*($bW -$tW) -0.5*$dpX*($bW -$tW)},{-$hg*($bW -$tW)+0.5*$dpY*($bW -$tW)}       l{-$dpX*$tW},{$dpY*$tW} z"/>
                        <path d="M{-$colW*$tW +0.5*$dpX*(1-$tW)},{-$hg*(1-$tW) -0.5*$dpY*(1-$tW)}       h{2*$colW*$tW}        l{$dpX*$tW},{-$dpY*$tW}       h{-2*$colW*$tW} z"/>
                    </xsl:when>
                    <xsl:when test="$type = 'line' ">
                        <!-- 3D line -->
                        <path d="M{0},{-$hg*(1-$bW)} v{-$hg*($bW -$tW)}" stroke-width="2" stroke-linecap="butt" stroke="{$color}"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <!--3D block and other types-->
                        <path d="M{-$colW},{-$hg*(1-$bW)} h{2*$colW} v{-$hg*($bW -$tW)} h{-2*$colW} z"/>
                        <path d="M{$colW},{-$hg*(1-$bW)} l{$dpX},{-$dpY} v{-$hg*($bW -$tW)} l{-$dpX},{$dpY} z"/>
                        <path d="M{-$colW},{-$hg*(1-$tW)} h{2*$colW} l{$dpX},{-$dpY} h{-2*$colW} z"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <!--2D a other types-->
                <xsl:choose>
                    <xsl:when test="$type = 'cylinder' ">
                        <!--2D cylinder-->
                        <path d="M{-$colW},{-$hg*(1-$bW)} h{2*$colW} v{-$hg*($bW -$tW)} h{-2*$colW} z"/>
                    </xsl:when>
                    <xsl:when test="$type = 'cone' ">
                        <!--2D cone -->
                        <path d="M{-$colW*$bW},{-$hg*(1-$bW)} h{2*$colW*$bW} l{-$colW*($bW -$tW)},{-$hg*($bW -$tW)} h{-2*$colW*$tW} z"/>
                    </xsl:when>
                    <xsl:when test="$type = 'pyramid' ">
                        <!--2D pyramid -->
                        <path d="M{-$colW*$bW},{-$hg*(1-$bW)} h{2*$colW*$bW} l{-$colW*($bW -$tW)},{-$hg*($bW -$tW)} h{-2*$colW*$tW} z"/>
                    </xsl:when>
                    <xsl:when test="$type = 'line' ">
                        <!-- 2D line -->
                        <path d="M{0},{-$hg*(1-$bW)} v{-$hg*($bW -$tW)}" stroke-width="2" stroke-linecap="butt" stroke="{$color}"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <!--2D block a other types -->
                        <path d="M{-$colW},{-$hg*(1-$bW)} h{2*$colW} v{-$hg*($bW -$tW)} h{-2*$colW} z"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:function name="m:Arc">
        <!-- return SVG path drawing an half-ellips in positive direction -->
        <xsl:param name="dx"/>
        <xsl:param name="hg"/>
        <xsl:param name="sp"/>
        <xsl:value-of select="concat('a', math:abs($dx), ',', $hg, ' 0 0,', $sp, ' ', 2*$dx, ',0')"/>
    </xsl:function>
    <xsl:template name="m:drawPoint">
        <!--draw a point (mark) of a given type -->
        <xsl:param name="type"/>
        <xsl:param name="x" select="0"/>
        <xsl:param name="y" select="0"/>
        <xsl:param name="color" select="black"/>
        <xsl:variable name="poS" select="1.5"/>
        <xsl:variable name="crS" select="3"/>
        <xsl:variable name="plS" select="4"/>
        <xsl:variable name="miS" select="3"/>
        <xsl:variable name="stS" select="4"/>
        <xsl:variable name="sqS" select="3"/>
        <xsl:variable name="ciS" select="4"/>
        <xsl:variable name="trS" select="4"/>
        <xsl:variable name="rhS" select="4"/>
        <xsl:choose>
            <xsl:when test="$type = 'point'">
                <circle cx="{$x}" cy="{$y}" r="{$poS}" fill="currentColor">
                    <xsl:if test="($color != 'inh')">
                        <xsl:attribute name="stroke" select="$color"/>
                        <xsl:attribute name="color" select="$color"/>
                    </xsl:if>
                </circle>
            </xsl:when>
            <xsl:when test="$type = 'cross' ">
                <path d="M {$x},{$y} m {- $crS},{- $crS} l {2 * $crS},{2 * $crS} m 0,{- 2 * $crS} l {- 2 * $crS},{2 * $crS}">
                    <xsl:if test="($color != 'inh')">
                        <xsl:attribute name="stroke" select="$color"/>
                    </xsl:if>
                </path>
            </xsl:when>
            <xsl:when test="$type = 'plus' ">
                <path d="M {$x},{$y} m {- $plS},0 l {2 * $plS},0 m {- $plS},{- $plS} l 0,{2 * $plS}">
                    <xsl:if test="($color != 'inh')">
                        <xsl:attribute name="stroke" select="$color"/>
                    </xsl:if>
                </path>
            </xsl:when>
            <xsl:when test="$type = 'minus' ">
                <path d="M{$x},{$y} m{-$miS},0 h{2*$miS}">
                    <xsl:if test="($color != 'inh')">
                        <xsl:attribute name="stroke" select="$color"/>
                    </xsl:if>
                </path>
            </xsl:when>
            <xsl:when test="$type = 'star'">
                <path d="M {$x},{$y} m 0,{- $stS} l 0,{2 * $stS} m {- $stS * 0.87},{- $stS * 1.5} l {$stS * 1.73},{$stS}      m {- $stS * 1.73},0 l {$stS * 1.73},{-$stS}">
                    <xsl:if test="($color != 'inh')">
                        <xsl:attribute name="stroke" select="$color"/>
                    </xsl:if>
                </path>
            </xsl:when>
            <!--xsl:when test="$type = 'star2'">
			<path d="M {$x},{$y} m {- $stS},0 l {2 * $stS},0 m {- $stS * 1.5},{- $stS * 0.87} l {$stS},{$stS * 1.73}
					m 0,{- $stS * 1.73} l {-$stS},{$stS * 1.73}">
				<xsl:if test="($color != 'inh')">
					<xsl:attribute name="stroke" select="$color"/>
				</xsl:if>
			</path>
		</xsl:when-->
            <xsl:when test="$type = 'square'">
                <path d="M {$x},{$y} m {- $sqS},{- $sqS} l {2 * $sqS},0 l 0,{2 * $sqS} l {- 2 * $sqS},0 z">
                    <xsl:if test="($color != 'inh')">
                        <xsl:attribute name="stroke" select="$color"/>
                    </xsl:if>
                </path>
            </xsl:when>
            <xsl:when test="$type = 'circle'">
                <circle cx="{$x}" cy="{$y}" r="{$ciS}">
                    <xsl:if test="($color != 'inh')">
                        <xsl:attribute name="stroke" select="$color"/>
                    </xsl:if>
                </circle>
            </xsl:when>
            <xsl:when test="$type = 'triangle'">
                <path d="M {$x},{$y} m {$trS},{- $trS * 0.58} l {-2 * $trS},0 l {$trS},{$trS * 1.73} z">
                    <xsl:if test="($color != 'inh')">
                        <xsl:attribute name="stroke" select="$color"/>
                    </xsl:if>
                </path>
            </xsl:when>
            <xsl:when test="$type = 'rhomb'">
                <path d="M {$x},{$y} m 0,{- $rhS} l {$rhS},{$rhS} l {- $rhS},{$rhS} l {- $rhS},{- $rhS} z">
                    <xsl:if test="($color != 'inh')">
                        <xsl:attribute name="stroke" select="$color"/>
                    </xsl:if>
                </path>
            </xsl:when>
            <xsl:when test="$type = 'pyramid'">
                <path d="M {$x},{$y} m {$trS},{$trS * 0.58} l {-2 * $trS},0 l {$trS},{- $trS * 1.73} z">
                    <xsl:if test="($color != 'inh')">
                        <xsl:attribute name="stroke" select="$color"/>
                    </xsl:if>
                </path>
            </xsl:when>
            <xsl:when test="$type = 'squareF'">
                <path d="M {$x},{$y} m {- $sqS},{- $sqS} l {2 * $sqS},0 l 0,{2 * $sqS} l {- 2 * $sqS},0 z" fill="currentColor">
                    <xsl:if test="($color != 'inh')">
                        <xsl:attribute name="stroke" select="$color"/>
                        <xsl:attribute name="color" select="$color"/>
                    </xsl:if>
                </path>
            </xsl:when>
            <xsl:when test="$type = 'circleF'">
                <circle cx="{$x}" cy="{$y}" r="{$ciS}" fill="currentColor">
                    <xsl:if test="($color != 'inh')">
                        <xsl:attribute name="stroke" select="$color"/>
                        <xsl:attribute name="color" select="$color"/>
                    </xsl:if>
                </circle>
            </xsl:when>
            <xsl:when test="$type = 'triangleF'">
                <path d="M {$x},{$y} m {$trS},{- $trS * 0.58} l {-2 * $trS},0 l {$trS},{$trS * 1.73} z" fill="currentColor">
                    <xsl:if test="($color != 'inh')">
                        <xsl:attribute name="stroke" select="$color"/>
                        <xsl:attribute name="color" select="$color"/>
                    </xsl:if>
                </path>
            </xsl:when>
            <xsl:when test="$type = 'rhombF'">
                <path d="M {$x},{$y} m 0,{- $rhS} l {$rhS},{$rhS} l {- $rhS},{$rhS} l {- $rhS},{- $rhS} z" fill="currentColor">
                    <xsl:if test="($color != 'inh')">
                        <xsl:attribute name="stroke" select="$color"/>
                        <xsl:attribute name="color" select="$color"/>
                    </xsl:if>
                </path>
            </xsl:when>
            <xsl:when test="$type = 'pyramidF'">
                <path d="M {$x},{$y} m {$trS},{$trS * 0.58} l {-2 * $trS},0 l {$trS},{- $trS * 1.73} z" fill="currentColor">
                    <xsl:if test="($color != 'inh')">
                        <xsl:attribute name="stroke" select="$color"/>
                        <xsl:attribute name="color" select="$color"/>
                    </xsl:if>
                </path>
            </xsl:when>
            <xsl:otherwise> </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:function name="m:GMax">
        <!-- truncates up the maximum (of an axis) to the whole axis steps -->
        <xsl:param name="max"/>
        <xsl:param name="step"/>
        <xsl:variable name="pom" select="$step * ceiling($max div $step)"/>
        <xsl:value-of select="    if (($pom = 0)  or (($pom &gt; 0) and ($pom != $max))) then $pom else ($pom +$step) "/>
    </xsl:function>
    <xsl:function name="m:Step">
        <!-- returns a lenght of axes step -->
        <xsl:param name="dif"/>
        <xsl:param name="count"/>
        <xsl:variable name="ps" select="($dif) div $count"/>
        <xsl:variable name="rad" select="floor(m:Log10($ps))"/>
        <xsl:variable name="cif" select="$ps div math:power(10, $rad)"/>
        <xsl:variable name="st" select="   if ($cif &lt; 1.6) then 1 else   if ($cif &lt; 2.2) then 2 else   if ($cif &lt; 4) then 2.5 else   if ($cif &lt; 9) then 5 else 10"/>
        <xsl:value-of select="$st * math:power(10, $rad)"/>
        <!--xsl:variable name="st">
		<xsl:choose>
			<xsl:when test="$cif < 1.6"><xsl:value-of select="1"/></xsl:when>
			<xsl:when test="$cif < 2.2"><xsl:value-of select="2"/></xsl:when>
			<xsl:when test="$cif < 4"><xsl:value-of select="2.5"/></xsl:when>
			<xsl:when test="$cif < 9"><xsl:value-of select="5"/></xsl:when>
			<xsl:otherwise><xsl:value-of select="10"/></xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	<xsl:variable name="pom" select="$st"/>
	<xsl:value-of select="$pom * math:power(10, $rad)"/-->
    </xsl:function>

    <!-- rounds the value on same number of decimal places as has the step, used for printing values on axes -->
    <xsl:function name="m:Round">
        <xsl:param name="val"/>
        <xsl:param name="step"/>
        <xsl:variable name="rad" select="floor(m:Log10($step))"/>
        <xsl:variable name="pom" select="round($val * math:power(10, - $rad +1)) * math:power(10, $rad - 1)"/>
        <xsl:value-of select="if ($pom != 0) then format-number($pom, '#.##############') else $pom"/>
    </xsl:function>

    <!-- rounds the value on 2 decimal places, used for coordinates -->
    <xsl:function name="m:R">
        <xsl:param name="val"/>
        <xsl:value-of select="round($val * 100) div 100"/>
    </xsl:function>

    <!-- calculate logarithm to the base 10 -->
    <xsl:function name="m:Log10">
        <xsl:param name="val"/>
        <xsl:variable name="const" select="0.43429448190325182765112891891661"/>
        <!--log_10 (e)-->
        <xsl:value-of select="$const*math:log($val)"/>
    </xsl:function>
</xsl:stylesheet><!--
 # Software distributed under the License is distributed on an "AS IS" basis,
 # WITHOUT WARRANTY OF ANY KIND, either express or implied.
 # See the License for rights and limitations under the License.
 # osgr2svg.xsl enerates an SVG file from an xml file valid to osgr.rng
 # Copyright (C) 2007  Jakub Vojtisek
 # Contribution: Dave Pawson
 #
 # This program is free software; you can redistribute it and/or modify
 # it under the terms of the GNU General Public License as published by
 # the Free Software Foundation; either version 2 of the License, or (at
 # your option) any later version.
 #
 # This program is distributed in the hope that it will be useful,
 # but WITHOUT ANY WARRANTY; without even the implied warranty of
 # MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 # GNU General Public License for more details.
 #
 # You should have received a copy of the GNU General Public License
 # along with this program; if not, write to the Free Software
 # Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
 # 02110-1301, USA.
 #
 # Software distributed under the License is distributed on an "AS IS" basis,
 # WITHOUT WARRANTY OF ANY KIND, either express or implied.
 # See the License for rights and limitations under the License.
 -->
