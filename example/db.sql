--
-- PostgreSQL database dump
--

-- Dumped from database version 9.6.1
-- Dumped by pg_dump version 9.6.1

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: choices; Type: TABLE; Schema: public; Owner: jb
--

CREATE TABLE choices (
    doodleid integer NOT NULL,
    name text NOT NULL,
    choices json NOT NULL,
    id integer NOT NULL
);


ALTER TABLE choices OWNER TO jb;

--
-- Name: choices_id_seq; Type: SEQUENCE; Schema: public; Owner: jb
--

CREATE SEQUENCE choices_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE choices_id_seq OWNER TO jb;

--
-- Name: choices_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: jb
--

ALTER SEQUENCE choices_id_seq OWNED BY choices.id;


--
-- Name: doodles; Type: TABLE; Schema: public; Owner: jb
--

CREATE TABLE doodles (
    id integer NOT NULL,
    title text NOT NULL,
    options json NOT NULL
);


ALTER TABLE doodles OWNER TO jb;

--
-- Name: doodles_id_seq; Type: SEQUENCE; Schema: public; Owner: jb
--

CREATE SEQUENCE doodles_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE doodles_id_seq OWNER TO jb;

--
-- Name: doodles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: jb
--

ALTER SEQUENCE doodles_id_seq OWNED BY doodles.id;


--
-- Name: doodles_with_choices; Type: VIEW; Schema: public; Owner: jb
--

CREATE VIEW doodles_with_choices AS
 SELECT doodles.id,
    doodles.title,
    doodles.options,
    choices.name,
    choices.choices
   FROM (doodles
     LEFT JOIN choices ON ((doodles.id = choices.doodleid)))
  ORDER BY choices.id;


ALTER TABLE doodles_with_choices OWNER TO jb;

--
-- Name: choices id; Type: DEFAULT; Schema: public; Owner: jb
--

ALTER TABLE ONLY choices ALTER COLUMN id SET DEFAULT nextval('choices_id_seq'::regclass);


--
-- Name: doodles id; Type: DEFAULT; Schema: public; Owner: jb
--

ALTER TABLE ONLY doodles ALTER COLUMN id SET DEFAULT nextval('doodles_id_seq'::regclass);


--
-- Data for Name: choices; Type: TABLE DATA; Schema: public; Owner: jb
--

COPY choices (doodleid, name, choices, id) FROM stdin;
5	JB	[true,false,false,false]	1
5	Prisca	[false,false,true,false]	2
5	Ruben	[false,true,false,false]	3
5	Alexis	[false,false,false,true]	4
5	Loic	[false,true,false,false]	5
6	JB	[true,false,false,false,true]	6
6	Daniel	[false,false,true,false,true]	7
6	Seb	[true,true,false,false,false]	8
6	Christophe	[false,false,false,true,false]	9
8	JB	[true,false]	10
8	Prisca	[true,false]	11
8	Ruben	[false,true]	12
8	Alexis	[true,false]	13
8	Loic	[true,false]	14
8	Daniel	[true,false]	15
8	Seb	[true,false]	16
8	Christophe	[true,false]	17
7	Me	[true,false,false]	18
7	You	[false,false,true]	19
7	Him	[false,false,true]	20
\.


--
-- Name: choices_id_seq; Type: SEQUENCE SET; Schema: public; Owner: jb
--

SELECT pg_catalog.setval('choices_id_seq', 35, true);


--
-- Data for Name: doodles; Type: TABLE DATA; Schema: public; Owner: jb
--

COPY doodles (id, title, options) FROM stdin;
5	Menu	["Vegetarian", "Meat", "Fish", "Vegan"]
6	Holidays location	["Lausanne", "Paris", "San Francisco", "Zurich", "Kathmandu"]
7	Meeting	["12/17/2016", "01/24/2017", "01/27/2017"]
8	Vote for president	["Clinton", "Trump"]
\.


--
-- Name: doodles_id_seq; Type: SEQUENCE SET; Schema: public; Owner: jb
--

SELECT pg_catalog.setval('doodles_id_seq', 12, true);


--
-- Name: choices choices_pkey; Type: CONSTRAINT; Schema: public; Owner: jb
--

ALTER TABLE ONLY choices
    ADD CONSTRAINT choices_pkey PRIMARY KEY (id);


--
-- Name: doodles doodles_pkey; Type: CONSTRAINT; Schema: public; Owner: jb
--

ALTER TABLE ONLY doodles
    ADD CONSTRAINT doodles_pkey PRIMARY KEY (id);


--
-- Name: choices choices_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: jb
--

ALTER TABLE ONLY choices
    ADD CONSTRAINT choices_id_fkey FOREIGN KEY (doodleid) REFERENCES doodles(id);


--
-- PostgreSQL database dump complete
--

