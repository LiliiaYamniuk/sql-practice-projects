--Used `CASE WHEN` to check for the presence of necessary chars in the text.
--Used the string functions STRPOS, REVERSE, and RIGHT to find and extract the necessary part of the text.

SELECT
  short_description,
  CASE
    WHEN
      (
        strpos(short_description, "x") > 0
        AND STRPOS(short_description, 'cm') > 0)
      THEN
        RIGHT(short_description, (strpos(reverse(short_description), "x")) - 1)
    END AS size_of_product
FROM `DA.product`





