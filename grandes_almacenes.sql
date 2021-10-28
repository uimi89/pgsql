--
-- PostgreSQL database dump
--

-- Dumped from database version 10.18
-- Dumped by pg_dump version 10.18

-- Started on 2021-10-28 13:37:45

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 1 (class 3079 OID 12924)
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- TOC entry 2819 (class 0 OID 0)
-- Dependencies: 1
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET default_tablespace = '';

SET default_with_oids = false;

--
-- TOC entry 196 (class 1259 OID 16394)
-- Name: cajeros; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.cajeros (
    "cajero " bigint NOT NULL,
    "nomApels " character varying NOT NULL
);


ALTER TABLE public.cajeros OWNER TO postgres;

--
-- TOC entry 199 (class 1259 OID 16410)
-- Name: maquinas_registradoras; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.maquinas_registradoras (
    "maquina " bigint NOT NULL,
    piso bigint NOT NULL
);


ALTER TABLE public.maquinas_registradoras OWNER TO postgres;

--
-- TOC entry 198 (class 1259 OID 16405)
-- Name: productos; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.productos (
    "producto " bigint NOT NULL,
    "nombre " character varying(100) NOT NULL,
    "precio " money NOT NULL
);


ALTER TABLE public.productos OWNER TO postgres;

--
-- TOC entry 197 (class 1259 OID 16402)
-- Name: venta; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.venta (
    "cajero " bigint NOT NULL,
    "maquina " bigint NOT NULL,
    "producto " bigint NOT NULL
);


ALTER TABLE public.venta OWNER TO postgres;

--
-- TOC entry 2808 (class 0 OID 16394)
-- Dependencies: 196
-- Data for Name: cajeros; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.cajeros ("cajero ", "nomApels ") FROM stdin;
1	Juan
2	Ana
3	Rocio
4	Jose
5	Gabriela
\.


--
-- TOC entry 2811 (class 0 OID 16410)
-- Dependencies: 199
-- Data for Name: maquinas_registradoras; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.maquinas_registradoras ("maquina ", piso) FROM stdin;
1	2
3	3
2	1
4	2
\.


--
-- TOC entry 2810 (class 0 OID 16405)
-- Dependencies: 198
-- Data for Name: productos; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.productos ("producto ", "nombre ", "precio ") FROM stdin;
1	disco duro	1.000,00 €
2	mesa	320.080,00 €
3	telefono	7.500,00 €
4	secadora	200,00 €
5	refrigerador	15.000,00 €
6	Sofa	4.000,00 €
\.


--
-- TOC entry 2809 (class 0 OID 16402)
-- Dependencies: 197
-- Data for Name: venta; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.venta ("cajero ", "maquina ", "producto ") FROM stdin;
2	3	4
2	1	2
1	1	1
5	2	6
5	3	5
4	3	2
3	2	3
\.


--
-- TOC entry 2682 (class 2606 OID 16401)
-- Name: cajeros cajeros_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cajeros
    ADD CONSTRAINT cajeros_pkey PRIMARY KEY ("cajero ");


--
-- TOC entry 2686 (class 2606 OID 16414)
-- Name: maquinas_registradoras maquinas_registradoras_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.maquinas_registradoras
    ADD CONSTRAINT maquinas_registradoras_pkey PRIMARY KEY ("maquina ");


--
-- TOC entry 2684 (class 2606 OID 16409)
-- Name: productos productos_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.productos
    ADD CONSTRAINT productos_pkey PRIMARY KEY ("producto ");


-- Completed on 2021-10-28 13:37:46

--
-- PostgreSQL database dump complete
--


-- CONSULTAS PARA LA REALIZACIÓN DEL EJERCICIO.

-- Consulta para mostrar el número de ventas de cada producto, ordenado de más a menos ventas.

SELECT productos.producto, productos.nombre, COUNT(venta.producto)

FROM productos JOIN venta ON productos.producto = venta.producto 

GROUP BY productos.producto, productos.nombre 
ORDER BY COUNT (venta.producto) DESC;


-- Consulta para obtener un informe completo de ventas, indicando el nombre del cajero que realizo la venta, nombre y precios de los productos vendidos, y el piso en el que se encuentra la máquina registradora donde se realizó la venta.
-- Sin Join.
SELECT nomApels, nombre, precio, piso
FROM  venta v, cajeros c, productos p, maquinas_registradoras m
WHERE v.cajero = c.cajero AND v.producto = p.producto AND v.maquina = m.maquina;

-- Con Join.
SELECT nomApels, nombre, precio, piso
FROM cajeros c JOIN (productos p JOIN 
(maquinas_registradoras m JOIN venta v ON v.maquina = m.maquina)
ON v.producto = p.producto) ON v.cajero = c.cajero;


-- Consulta para obtener las ventas totales realizadas en cada piso.

SELECT piso, SUM(precio) AS ventas_totales FROM venta v, productos p, maquinas_registradoras m
WHERE v.producto = p.producto AND v.maquina = m.maquina GROUP BY piso;


-- Consulta para obtener el código y nombre de cada cajero junto con el importe total de sus ventas.

SELECT c.cajero, c.nomApels, SUM(precio) AS importe_total_ventas FROM productos p 
JOIN (cajeros c JOIN venta v ON v.cajero = c.cajero) 
ON v.producto = p.producto GROUP BY c.cajero;

-- Consulta para obtener el código y nombre de aquellos cajeros que hayan realizado ventas en pisos cuyas ventas totales sean inferiores a los 5000 pesos.

SELECT cajero, nomApels FROM cajeros WHERE cajero IN
(SELECT  cajero FROM venta WHERE maquina  IN 
(SELECT maquina FROM maquinas_registradoras WHERE piso IN 
(SELECT piso FROM venta v, productos p, maquinas_registradoras m
WHERE v.producto = p.producto AND v.maquina = m.maquina
GROUP BY piso HAVING SUM(precio)<5000)));  