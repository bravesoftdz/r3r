<?php

/**
  * @package Networking
*/

/* Functions for parsing various types of feeds */

/* RSS 3.0 parsing functions */

/* Common Functions */

/**
  * Tests whether the input line is blank
  * @param String a string to test
  * @return Boolean Whether the line was blank
*/
function isBlankLine($str)
{
  return preg_match('/^[\r|\n]+$/', $str);
}

/**
  * Internalizes the current item.
  * @param String The name of the current item
  * @param String The value of the current item
  * @param Boolean Whether the feed type is XML
  * @return The processed field name
*/
function internalizeItem($fn, $fv)
{
  global $feeds, $itemIndex;

  $fv = html_entity_decode($fv);
  $fn = normalizeXmlNames($fn);

  if ($fn)
  {
    $feeds[$itemIndex][$fn] = $fv;
    return $fn;
  }
}

/**
  * Parse a line of an RSS 3.0 feed and fill an array with the information.
  * @param String A line of an RSS 3.0 feed
*/
function parseTxt($str)
{
  global $itemIndex;
  static $fieldName, $fieldVal;
  static $lastIndex = 0;

  if (preg_match('/^\w+/', $str))
  {
    $lastIndex++;
    $colonidx = strpos($str, ':');
    $fieldName = substr($str, 0, $colonidx ? $colonidx : strlen($str));
    $fieldVal = trim(substr($str, $colonidx + 1));
    if ($colonidx)
      $fieldName = strtolower($fieldName);

    if (getSetting('show-warnings') && $itemIndex > -1)
    {
      if (!$colonidx)
        alert(ALERT_INVALID_LINE_NAME . "\n\n$fieldName", ALERT_WARNING);

      if (strlen($fieldVal) > 80)
        alert(ALERT_LONG_LINE, ALERT_WARNING);
    }
  }
  else if (isBlankLine($str))
  {
    if ($lastIndex != $itemIndex)
      $itemIndex++;
    $lastIndex = $itemIndex;

    if ($itemIndex != 0)
      $fieldName = '';

    if (getSetting('show-warnings') && strpos($str, "\r"))
      alert(ALERT_CR, ALERT_WARNING);
  }
  else if (preg_match('/^\s+\S/', $str))
    $fieldVal .= "\n" . preg_replace('/\s+/', ' ', $str);

  internalizeItem($fieldName, $fieldVal);
}

/* ESF functions */

/**
  * Parse a line of an ESF feed and fill an array with the information.
  * @param String A line of an ESF feed
*/
function parseEsf($str)
{
  global $feeds, $itemIndex;

  $items = array('created', 'title', 'link');
  $arr = explode("\t", trim($str));
  $narr = count($arr);

  if (isBlankLine($str) || substr($str, 0, 1) == '#')
    return;
  else if ($narr == 3)
  {
    if ($itemIndex == 0)
      $itemIndex++;

    for ($idx = 0; $idx < 3; $idx++)
    {
      $fieldName = $items[$idx];
      $fieldVal = $arr[$idx];

      if ($items[$idx] == 'created')
      {
        if (($uts = strtotime($fieldVal)) === -1)
          $uts = $fieldVal;

        $fieldVal = date('Y-m-d', $uts);
      }

      internalizeItem($fieldName, $fieldVal);
    }
  }
  else if ($narr == 2)
  {
    list($fieldName, $fieldVal) = $arr;
    internalizeItem($fieldName, $fieldVal);
    return;
  }

  if (count($feeds[$itemIndex]) > 0)
    $itemIndex++;
}

/* XML-based feed parsing */

/**
  * Name of the current element
  * @access private
*/
$_xml_fn = '';
/**
  * Element content
  * @access private
*/
$_xml_fv = '';
/**
  * The current XML parser
  * @access private
*/
$_xml_parser = null;

/**
  * Convert XML element names to values that are understood internally.
  * @param String Textualized XML element
  * @return String Proper string value for processing
*/
function normalizeXmlNames($fieldName)
{
  $fieldName = preg_replace('/^dc:/', '', $fieldName);

  switch ($fieldName)
  {
    case 'category':
      $fieldName = 'subject';
      break;
    case 'items':
      $fieldName = 'item';
      break;
    case 'lastBuildDate':
      $fieldName = 'last-modified';
      break;
    /* The following conversions are for Atom 0.2. 
       May be removed in future versions */
    case 'copyright':
      $fieldName = 'rights';
      break;
    case 'email':
      $fieldName = 'creator';
      break;
    case 'entry':
    case 'feed':
      $fieldName = 'item';
      break;
    case 'id':
      $fieldName = 'guid';
      break;
    case 'modified':
      $fieldName = 'last-modified';
      break;
    case 'summary':
      $fieldName = 'description';
      break;
  }

  return $fieldName;
}

/**
  * Start XML tag found
  * @param Resource The XML parser
  * @param String The tag name
  * @param Array Element attributes
*/
function _xml_start($parser, $name, $attr)
{
  global $_xml_fn, $itemIndex;

  $_xml_fn = $name;

  if ($_xml_fn == 'item')
    $itemIndex++;
}

/**
  * End XML tag found
  * @param Resource The XML parser
  * @param String The tag name
*/
function _xml_end($parser, $name)
{
  global $_xml_fn, $_xml_fv;
  $_xml_fn = '';
  $_xml_fv = '';
}

/**
  * XML character data found
  * @param Resource The XML parser
  * @param String The character data
*/
function _xml_cdata($parser, $data)
{
  global $_xml_fn, $_xml_fv;

  $_xml_fv .= ltrim($data);

  if ($_xml_fv)
    internalizeItem($_xml_fn, $_xml_fv);
}

/**
  * Parse a line of an XML feed and fill an array with the information.
  * @param String A line of an XML feed
*/
function parseXml($str)
{
  global $_xml_parser;

  if (!$_xml_parser)
  {
    $_xml_parser = xml_parser_create();
    xml_parser_set_option($_xml_parser, XML_OPTION_CASE_FOLDING, false);
    xml_set_element_handler($_xml_parser, '_xml_start', '_xml_end');
    xml_set_character_data_handler($_xml_parser, '_xml_cdata');
  }

  xml_parse($_xml_parser, $str);
}

/**
  * Frees the current XML parser from memory
*/
function freeXmlParser()
{
  global $_xml_parser;

  if ($_xml_parser)
  {
    xml_parser_free($_xml_parser);
    $_xml_parser = null;
  }
}

?>
