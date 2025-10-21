/*
Navicat MySQL Data Transfer

Source Server         : c1
Source Server Version : 50126
Source Host           : localhost:3306
Source Database       : dispositivos_moviles

Target Server Type    : MYSQL
Target Server Version : 50126
File Encoding         : 65001

Date: 2014-09-11 21:51:05
*/

SET FOREIGN_KEY_CHECKS=0;
-- ------------------------------------------------------------------
-- Table structure for `lecturas`
-- ------------------------------------------------------------------
DROP TABLE IF EXISTS `lecturas`;
CREATE TABLE `lecturas` (
  `numero_de_lectura` int(11) NOT NULL AUTO_INCREMENT,
  `id_dispositivo` text NOT NULL COMMENT 'Identificador del dispositivo.',
  `fecha_hora` datetime NOT NULL COMMENT 'Fecha y hora de la realización de la lectura.',
  `nombre_de_lugar` text NOT NULL COMMENT 'Nombre del lugar o identificador.',
  `longitud` double NOT NULL COMMENT 'Longitud de las coordenadas del lugar en WGS84',
  `latitud` double NOT NULL COMMENT 'Latitud de las coordenadas del lugar en WGS84',
  PRIMARY KEY (`numero_de_lectura`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8;


-- ------------------------------------------------------------------
-- Records of lecturas
-- ------------------------------------------------------------------
INSERT INTO `lecturas` VALUES ('1', '15DDF4C3', '2014-09-05 21:32:46', 'Alamar Zona 21', '-82.265897', '23.172091');
INSERT INTO `lecturas` VALUES ('2', 'FFC1589E', '2014-09-05 21:33:14', 'Alamar Zona 21', '-82.265898', '23.172091');
INSERT INTO `lecturas` VALUES ('3', 'FFC1589E', '2014-09-05 21:40:32', 'Alamar Zona 23', '-82.269273', '23.172291');
INSERT INTO `lecturas` VALUES ('4', 'FFC1589E', '2014-09-05 21:51:48', 'Alamar Zona 23', '-82.269275', '23.172295');
INSERT INTO `lecturas` VALUES ('5', 'FFC1589E', '2014-09-05 22:45:40', 'Alamar Zona 21', '-82.265894', '23.172092');
INSERT INTO `lecturas` VALUES ('6', 'FFC1589E', '2014-09-05 22:56:45', 'Alamar Zona 17', '-82.262942', '23.172698');
INSERT INTO `lecturas` VALUES ('7', '15DDF4C3', '2014-09-05 22:56:49', 'Alamar Zona 17', '-82.262945', '23.17269');



-- ------------------------------------------------------------------
-- Function structure for `minutos_entre`
-- ------------------------------------------------------------------
DELIMITER ;;
DROP FUNCTION IF EXISTS `minutos_entre`;;
CREATE FUNCTION `minutos_entre`(
    `FT1` DATETIME,  	-- Fecha y hora del suceso 1
    `FT2` DATETIME		-- Fecha y hora del suceso 2
) RETURNS FLOAT
DETERMINISTIC
READS SQL DATA
BEGIN
    RETURN ABS(TIMESTAMPDIFF(SECOND, FT1, FT2)) / 60.0;
END;;
DELIMITER ;



-- ------------------------------------------------------------------
-- Function structure for `metros_entre`
-- ------------------------------------------------------------------
DELIMITER ;;
DROP FUNCTION IF EXISTS `metros_entre`;;
CREATE FUNCTION `metros_entre`(
    `lat1` DOUBLE, `lon1` DOUBLE,	-- Coordenadas del suceso 1
    `lat2` DOUBLE, `lon2` DOUBLE	-- Coordenadas del suceso 2
) RETURNS DOUBLE
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE R DOUBLE DEFAULT 6371000; 	-- Radio de Tierra en metros
    DECLARE dLat DOUBLE;
    DECLARE dLon DOUBLE;
    DECLARE a DOUBLE;
    DECLARE c DOUBLE;
	
    -- Convertir diferencias a radianes
    SET dLat = RADIANS(lat2 - lat1);
    SET dLon = RADIANS(lon2 - lon1);
	
	-- Fórmula Haversine
    SET a = SIN(dLat/2) * SIN(dLat/2) + 
            COS(RADIANS(lat1)) * COS(RADIANS(lat2)) * 
            SIN(dLon/2) * SIN(dLon/2);
			
    SET c = 2 * ATAN2(SQRT(a), SQRT(1-a));

    RETURN R * c;
END;;
DELIMITER ;




-- ------------------------------------------------------------------
-- UBICACION DE UN DISPOSITIVO
-- Devuelve lista de las ubicaciones donde ha estado el dispositivo.
-- ------------------------------------------------------------------

DELIMITER ;;
CREATE PROCEDURE ubicacion_del_dispositivo(
    IN p_id_dispositivo VARCHAR(50)
)
BEGIN
    SELECT 
        fecha_hora AS fecha_hora,
        latitud AS latitud,
        longitud AS longitud,
        nombre_de_lugar AS ubicacion
    FROM lecturas
    WHERE id_dispositivo = p_id_dispositivo		
    ORDER BY fecha_hora DESC
    LIMIT 100;
END;;
DELIMITER ;




-- ------------------------------------------------------------------
-- CONSULTA DE PRESENCIA DE DISPOSITIVOS
-- Devuelve la lista de dispositivos que han estado cerca de la
-- localización especificada, cercano a la fecha y hora que se
-- ha especificado.
-- ------------------------------------------------------------------

DELIMITER ;;
CREATE PROCEDURE presencia_de_dispositivos_en(
    IN p_latitud DECIMAL(10, 8),
    IN p_longitud DECIMAL(11, 8),
    IN p_fecha_hora DATETIME
)
BEGIN
    SELECT 
        id_dispositivo AS dispositivo,
        fecha_hora AS fecha_hora,
        ROUND(latitud, 6) AS latitud,
        ROUND(longitud, 6) AS longitud,
        nombre_de_lugar AS ubicacion
    FROM lecturas
    WHERE
        -- Verifica la fecha y hora con una diferencia máxima de 5 minutos.
        minutos_entre(fecha_hora, p_fecha_hora) <= 5
        
        -- Verifica coordenada de la localización con una tolerancia de 50 metros.
        AND metros_entre(latitud, longitud, p_latitud, p_longitud) <= 50	
    ORDER BY fecha_hora DESC
    LIMIT 100;
END;;
DELIMITER ;




-- ------------------------------------------------------------------
-- CONSULTA DE COINCIDENCIA ENTRE DISPOSITIVOS
-- Devuelve las coincidencias espacio-temporales entre dos dispositivos .
-- ------------------------------------------------------------------

DELIMITER ;;
CREATE PROCEDURE coincidencias_entre_dispositivos(
    IN p_id_dispositivo_a VARCHAR(50),
    IN p_id_dispositivo_b VARCHAR(50)
)
BEGIN
    SELECT 
        L1.id_dispositivo AS dispositivo_a,
        L2.id_dispositivo AS dispositivo_b,
        L1.nombre_de_lugar AS lugar_de_coincidencia,
        ROUND(metros_entre(L1.latitud, L1.longitud, L2.latitud, L2.longitud), 2) 
        AS distancia_en_metros,
        ROUND(minutos_entre(L1.fecha_hora, L2.fecha_hora), 2) 
        AS minutos_de_diferencia
    FROM 
        lecturas AS L1
    INNER JOIN 
        lecturas AS L2 ON L1.id_dispositivo = p_id_dispositivo_a 
            AND L2.id_dispositivo = p_id_dispositivo_b
            AND ABS(minutos_entre(L1.fecha_hora, L2.fecha_hora)) <= 5 
            AND metros_entre(L1.latitud, L1.longitud, L2.latitud, L2.longitud) <= 500
    ORDER BY L1.fecha_hora DESC
    LIMIT 100;
END;;
DELIMITER ;



-- ------------------------------------------------------------------
-- CONSULTA DE COINCIDENCIA ENTRE GRUPOS DE DISPOSITIVOS
-- Devuelve las coincidencias espacio-temporales entre dos grupos.
-- ------------------------------------------------------------------

DELIMITER ;;
CREATE PROCEDURE coincidencias_entre_grupos(
    IN p_lista_dispositivos_a TEXT,
    IN p_lista_dispositivos_b TEXT
)
BEGIN
    SELECT 
        L1.id_dispositivo AS dispositivo_a,
        L2.id_dispositivo AS dispositivo_b,
        L1.nombre_de_lugar AS lugar_de_coincidencia,
        ROUND(metros_entre(L1.latitud, L1.longitud, L2.latitud, L2.longitud), 2) 
        AS distancia_en_metros,
        ROUND(minutos_entre(L1.fecha_hora, L2.fecha_hora), 2) 
        AS minutos_de_diferencia
    FROM 
        lecturas AS L1
    INNER JOIN 
        lecturas AS L2 ON L1.id_dispositivo < L2.id_dispositivo		
    WHERE
        FIND_IN_SET(L1.id_dispositivo, REPLACE(p_lista_dispositivos_a, ' ', ''))
        AND FIND_IN_SET(L2.id_dispositivo, REPLACE(p_lista_dispositivos_b, ' ', ''))
        AND ABS(minutos_entre(L1.fecha_hora, L2.fecha_hora)) <= 15 
        AND metros_entre(L1.latitud, L1.longitud, L2.latitud, L2.longitud) <= 200
    ORDER BY L1.fecha_hora DESC
    LIMIT 100;
END;;
DELIMITER ;



-- ------------------------------------------------------------------
-- CONSULTA DE CONTEO DE COINCIDENCIAS
-- Cuenta las coincidencias un dispositivo con los otros de la db.
-- ------------------------------------------------------------------

DELIMITER ;;
CREATE PROCEDURE contar_coincidencias_con(
    IN p_id_dispositivo VARCHAR(50)
)
BEGIN
    SELECT 
        L1.id_dispositivo AS dispositivo_a,
        L2.id_dispositivo AS dispositivo_b,
        COUNT(*) AS coincidencias
    FROM lecturas AS L1
    INNER JOIN 
        lecturas AS L2 ON L1.id_dispositivo = p_id_dispositivo
			AND L1.id_dispositivo <> L2.id_dispositivo
			AND ABS(minutos_entre(L1.fecha_hora, L2.fecha_hora)) <= 15 
			AND metros_entre(L1.latitud, L1.longitud, L2.latitud, L2.longitud) <= 200
    GROUP BY L1.id_dispositivo, L2.id_dispositivo
    ORDER BY coincidencias DESC
    LIMIT 100;
END;;
DELIMITER ;



-- Formas de llamar
-- CALL ubicacion_del_dispositivo('FFC1589E');
-- CALL presencia_de_dispositivos_en(23.172092, -82.265894, '2014-09-05 22:45:40');
-- CALL coincidencias_entre_dispositivos('15DDF4C3', 'FFC1589E');
-- CALL coincidencias_entre_grupos('15DDF4C3,45F7135A,154D564C', 'FFC1589E,66FF137C,762F4CA1');
-- CALL contar_coincidencias_con('FFC1589E');




